#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
FEATURE=$(basename "$SCRIPT_DIR")

psql "$PG_URI" -f /usr/src/app/src/playground/FEATURES/${FEATURE}/init.sql

npx tsx --env-file=environments/.env.dev.pg src/playground/FEATURES/${FEATURE}/index.ts

psql "$PG_URI" -f /usr/src/app/src/playground/FEATURES/${FEATURE}/drop.sql
