FROM postgres:17-bullseye AS build

RUN apt-get update \
    && apt-get install -f -y --no-install-recommends \
        software-properties-common \
        build-essential \
        pkg-config \
        git \
        postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sraoss/pg_ivm.git -b v1.10 --single-branch \
    && cd /pg_ivm \
    && make && make install \
    && cd / \
    && rm -rf pg_ivm

RUN git clone https://github.com/citusdata/pg_cron.git -b v1.6.4 --single-branch \
    && cd /pg_cron \
    && export PATH=/usr/pgsql-17/bin:$PATH \
    && make && PATH=$PATH make install \
    && cd / \
    && rm -rf pg_cron


COPY ./init-db /docker-entrypoint-initdb.d/

CMD ["-c", "shared_preload_libraries=pg_cron,pg_ivm", "-c", "cron.database_name=postgres"]
