#!/bin/sh

set -e

echo "...Run app in [${NODE_ENV}] mode..."

if [  "${NODE_ENV}" = "production" ]; then
    echo "[...Running application in production mode...]"
    # npm run start:prod
    echo "[...Sweet sleeping...]"
    sleep infinity
elif [ "${NODE_ENV}" = "development" ]; then
    echo "[...Running application in development mode...]"

    echo "[...Sweet sleeping...]"
    sleep infinity
    # npm run start:dev
elif [ "${NODE_ENV}" = "testing" ]; then
    # Sleep container, because we don't need to start application, but just have opportunity to reset DB
    # & connect to the network (for testing purposes)
    echo "[...Sweet sleeping...]"
    sleep infinity
else
    echo "[...Do nothing, NODE_ENV is not set...]"
fi
