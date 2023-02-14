# Docker image for configuring Postgres DB for Franklin

This folder contains the resources for configuring a Postgres 13+ instance to use PGSTAC, including the addition of PostGIS.  The Dockerfile will be used by the Franklin deployment in its init container, but in order to test this work locally, a docker compose file is provided.  From this directory issue
```
docker-compose -f docker-compose.test.yaml up -d db
docker-compose -f docker-compose.test.yaml run pgstac_install
```
and observe the successful completion of the process.  Issue
```
docker-compose -f docker-compose.test.yaml down
```
to take down the related resources.
