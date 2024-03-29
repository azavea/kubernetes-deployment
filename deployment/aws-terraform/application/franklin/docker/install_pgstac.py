"""
Custom resource lambda handler to bootstrap Postgres db.
Source: https://github.com/developmentseed/eoAPI/blob/master/deployment/handlers/db_handler.py
"""
import argparse
import json
import os
import sys
from urllib.parse import quote

import boto3
import psycopg
import requests
from psycopg import sql
from psycopg.conninfo import make_conninfo
from pypgstac.db import PgstacDB
from pypgstac.migrate import Migrate


def create_db(cursor, db_name: str) -> None:
    """Create DB."""
    cursor.execute(
        sql.SQL("SELECT 1 FROM pg_catalog.pg_database " "WHERE datname = %s"), [db_name]
    )
    if cursor.fetchone():
        print(f"database {db_name} exists, not creating DB")
    else:
        print(f"database {db_name} not found, creating...")
        cursor.execute(
            sql.SQL("CREATE DATABASE {db_name}").format(db_name=sql.Identifier(db_name))
        )


def create_user(cursor, username: str, password: str) -> None:
    """Create User."""
    cursor.execute(
        sql.SQL(
            "DO $$ "
            "BEGIN "
            "  IF NOT EXISTS ( "
            "       SELECT 1 FROM pg_roles "
            "       WHERE rolname = {user}) "
            "  THEN "
            "    CREATE USER {username} "
            "    WITH PASSWORD {password}; "
            "  ELSE "
            "    ALTER USER {username} "
            "    WITH PASSWORD {password}; "
            "  END IF; "
            "END "
            "$$; "
        ).format(username=sql.Identifier(username), password=password, user=username)
    )


def create_permissions(cursor, db_name: str, username: str) -> None:
    """Add permissions."""
    cursor.execute(
        sql.SQL(
            "GRANT CONNECT ON DATABASE {db_name} TO {username};"
            "GRANT CREATE ON DATABASE {db_name} TO {username};"  # Allow schema creation
            "GRANT USAGE ON SCHEMA public TO {username};"
            "ALTER DEFAULT PRIVILEGES IN SCHEMA public "
            "GRANT ALL PRIVILEGES ON TABLES TO {username};"
            "ALTER DEFAULT PRIVILEGES IN SCHEMA public "
            "GRANT ALL PRIVILEGES ON SEQUENCES TO {username};"
            "GRANT pgstac_read TO {username};"
            "GRANT pgstac_ingest TO {username};"
            "GRANT pgstac_admin TO {username};"
        ).format(
            db_name=sql.Identifier(db_name),
            username=sql.Identifier(username),
        )
    )


def register_extensions(cursor) -> None:
    """Add PostGIS extension."""
    cursor.execute(sql.SQL("CREATE EXTENSION IF NOT EXISTS postgis;"))


def install_pgstac(
        dbname,
        username,
        password,
        host,
        port,
        admin_dbname,
        admin_username,
        admin_password,
):
    try:
        # params = event["ResourceProperties"]
        # connection_params = get_secret(params["conn_secret_arn"])
        # user_params = get_secret(params["new_user_secret_arn"])

        print("Connecting to admin DB...")
        admin_db_conninfo = make_conninfo(
            dbname=admin_dbname,
            user=admin_username,
            password=admin_password,
            host=host,
            port=port,
        )
        with psycopg.connect(admin_db_conninfo, autocommit=True) as conn:
            with conn.cursor() as cur:
                print("Creating database...")
                create_db(
                    cursor=cur,
                    db_name=dbname,
                )

                print("Creating user...")
                create_user(
                    cursor=cur,
                    username=username,
                    password=password,
                )

        # Install extensions on the user DB with
        # superuser permissions, since they will
        # otherwise fail to install when run as
        # the non-superuser within the pgstac
        # migrations.
        print("Connecting to STAC DB...")
        stac_db_conninfo = make_conninfo(
            dbname=dbname,
            user=username,
            password=password,
            host=host,
            port=port,
        )
        with psycopg.connect(stac_db_conninfo, autocommit=True) as conn:
            with conn.cursor() as cur:
                print("Registering PostGIS ...")
                register_extensions(cursor=cur)

        stac_db_admin_dsn = (
            "postgresql://{user}:{password}@{host}:{port}/{dbname}".format(
                dbname=dbname,
                user=username,
                password=quote(password),
                host=host,
                port=port,
            )
        )

        pgdb = PgstacDB(dsn=stac_db_admin_dsn, debug=True)
        print(f"Current {pgdb.version=}")

        # As admin, run migrations
        print("Running migrations...")
        Migrate(pgdb).run_migration(os.environ["PGSTAC_VERSION"])

        # Assign appropriate permissions to user (requires pgSTAC migrations to have run)
        with psycopg.connect(admin_db_conninfo, autocommit=True) as conn:
            with conn.cursor() as cur:
                print("Setting permissions...")
                create_permissions(
                    cursor=cur,
                    db_name=dbname,
                    username=username,
                )

        print("Adding mosaic index...")
        with psycopg.connect(
            stac_db_admin_dsn,
            autocommit=True,
            options="-c search_path=pgstac,public -c application_name=pgstac",
        ) as conn:
            conn.execute(
                sql.SQL(
                    "CREATE INDEX IF NOT EXISTS searches_mosaic ON searches ((true)) WHERE metadata->>'type'='mosaic';"
                )
            )

    except Exception as e:
        print(f"Unable to bootstrap database with exception={e}")
        return 1

    print("Complete.")
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--database-name',
        type=str,
        required=True,
        help="Name of the database for storing Franklin assets"
    )
    parser.add_argument(
        '--database-host',
        type=str,
        required=True,
        help="Fully-qualified domain name for the database"
    )
    parser.add_argument(
        '--database-port',
        type=int,
        default=5432,
        help="Port number for the database"
    )
    parser.add_argument(
        '--username',
        type=str,
        required=True,
        help='Database username'
    )
    parser.add_argument(
        '--password',
        type=str,
        required=True,
        help='Database password'
    )
    parser.add_argument(
        '--admin-database-name',
        type=str,
        required=False,
        default='postgres',
        help="Name of the admin database (used to create the target DB) [default=postgres]"
    )
    parser.add_argument(
        '--admin-username',
        type=str,
        required=False,
        help="Username for the admin database (if different from --username)"
    )
    parser.add_argument(
        '--admin-password',
        type=str,
        required=False,
        help="Password for the admin database (if different from --password)"
    )
    args = parser.parse_args()

    sys.exit(
        install_pgstac(
            args.database_name,
            args.username,
            args.password,
            args.database_host,
            args.database_port,
            args.admin_database_name,
            args.admin_username if args.admin_username is not None else args.username,
            args.admin_password if args.admin_password is not None else args.password
        )
    )
