#!/bin/bash
echo "Running redis pre-entrypoint init script"

mkdir -p /etc/redis
cp /opt/redis/redis.conf /etc/redis/redis.conf

exec "$@"
