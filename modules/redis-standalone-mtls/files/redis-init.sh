#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

echo "Running redis pre-entrypoint init script"

mkdir -p /etc/redis
cp /opt/redis/redis.conf /etc/redis/redis.conf

exec "$@"
