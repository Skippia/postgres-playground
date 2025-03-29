FROM postgres:16

# Install build dependencies and pg_cron
RUN apt-get update && apt-get install -y \
    postgresql-16-cron \
    && rm -rf /var/lib/apt/lists/*

COPY init-db /docker-entrypoint-initdb.d
