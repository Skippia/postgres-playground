#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
FEATURE=$(basename "$SCRIPT_DIR")

psql "$PG_URI" -f /usr/src/app/src/playground/FEATURES/10-full-text-search/${FEATURE}/up.sql

npx tsx --env-file=environments/.env.dev.pg src/playground/FEATURES/10-full-text-search/${FEATURE}/index.ts

psql "$PG_URI" -f /usr/src/app/src/playground/FEATURES/10-full-text-search/${FEATURE}/down.sql
