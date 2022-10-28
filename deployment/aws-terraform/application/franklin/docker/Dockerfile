FROM python:3.8.13

ARG PGSTAC_VERSION
RUN echo "Using PGSTAC Version ${PGSTAC_VERSION}"
ENV PGSTAC_VERSION=${PGSTAC_VERSION}

WORKDIR /tmp

RUN pip install requests psycopg[binary,pool] pypgstac==${PGSTAC_VERSION} boto3 -t /asset
COPY install_pgstac.py /asset/install_pgstac.py

CMD ["echo", "hello world database"]
