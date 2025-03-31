FROM postgres:16

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    build-essential \
    gnupg \
    curl \
    git \
    make \
    gcc \
    clang \
    pkg-config \
    libopenblas-dev \
    postgresql-server-dev-all \
    postgresql-16-cron \
&& rm -rf /var/lib/apt/lists/*


# Compile the plugin from sources and install it
RUN git clone https://github.com/sraoss/pg_ivm.git -b v1.10 --single-branch \
    && cd /pg_ivm \
    && make && make install \
    && cd / \
    && rm -rf pg_ivm


RUN chmod 755 /docker-entrypoint-initdb.d/*
RUN chown -R postgres:postgres /docker-entrypoint-initdb.d

COPY init-db /docker-entrypoint-initdb.d
