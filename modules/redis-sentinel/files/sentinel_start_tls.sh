#!/bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


set -e

# # Fail if required environment variables are not set
# if [ -z "$${HOSTNAME_FULL}" ]; then
#   echo "ERROR: HOSTNAME_FULL environment variable is required"
#   exit 1
# fi

# Create the /etc/redis directory if it doesn't exist
mkdir -p /etc/redis

# Generate the sentinel.conf file
cat <<EOF > /etc/redis/sentinel.conf
sentinel monitor ${redis_sentinel_leader_name} ${lbname} ${redis_port+1} 1

sentinel announce-hostnames yes
sentinel down-after-milliseconds ${redis_sentinel_leader_name} 5000
sentinel failover-timeout ${redis_sentinel_leader_name} 10000
sentinel parallel-syncs ${redis_sentinel_leader_name} 1
tls-port 26379
port 0
daemonize no
logfile ""
logfile /dev/stdout
sentinel resolve-hostnames yes
tls-replication yes
tls-cert-file /certs/fullchain.pem
tls-key-file /certs/privkey.pem
tls-ca-cert-file /certs/isrgrootx1.pem
tls-auth-clients yes
EOF

# Start Redis Sentinel in the foreground
exec redis-server /etc/redis/sentinel.conf --sentinel
