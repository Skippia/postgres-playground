#!/bin/bash

cat <<EOT >> /var/lib/postgresql/data/postgresql.conf
shared_preload_libraries='pg_cron,pg_trgm,unaccent'
pg_cron.database_name='postgres'
default_text_search_config = 'english'
EOT
