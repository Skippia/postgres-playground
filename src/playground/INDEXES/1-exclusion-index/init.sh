#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
FEATURE=$(basename "$SCRIPT_DIR")

psql "$PG_URI" -f /usr/src/app/src/playground/INDEXES/${FEATURE}/up.sql

npx tsx --env-file=environments/.env.dev.pg src/playground/INDEXES/${FEATURE}/index.ts

psql "$PG_URI" -f /usr/src/app/src/playground/INDEXES/${FEATURE}/down.sql
