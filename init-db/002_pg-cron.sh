#!/bin/bash

cat <<EOT >> /var/lib/postgresql/data/postgresql.conf
shared_preload_libraries='pg_ivm'
EOT
