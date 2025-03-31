FROM postgres:17-bullseye AS build

RUN apt-get update \
    && apt-get install -f -y --no-install-recommends \
        software-properties-common \
        build-essential \
        pkg-config \
        git \
        postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

# Compile the plugin from sources and install it
RUN git clone https://github.com/sraoss/pg_ivm.git -b v1.10 --single-branch \
    && cd /pg_ivm \
    && make && make install \
    && cd / \
    && rm -rf pg_ivm

FROM postgres:17-bullseye

RUN apt-get update \
    && apt-get install -f -y --no-install-recommends \
        software-properties-common \
        build-essential \
        pkg-config \
        git \
        postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/citusdata/pg_cron.git -b v1.6.4 --single-branch \
    && cd /pg_cron \
    && export PATH=/usr/pgsql-17/bin:$PATH \
    && make && PATH=$PATH make install \
    && cd / \
    && rm -rf pg_cron

COPY --from=build /usr/lib/postgresql/$PG_MAJOR/lib/ /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=build /usr/share/postgresql/$PG_MAJOR/extension/pg_ivm.control /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=build /usr/share/postgresql/$PG_MAJOR/extension/pg_ivm*.sql /usr/share/postgresql/$PG_MAJOR/extension/

COPY ./init-db /docker-entrypoint-initdb.d/

CMD ["-c", "shared_preload_libraries=pg_cron,pg_ivm", "-c", "cron.database_name=postgres"]
