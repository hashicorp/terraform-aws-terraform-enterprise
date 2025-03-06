#!/bin/sh

set -e

# Fail if required environment variables are not set
if [ -z "$${HOST_IP}" ]; then
  echo "ERROR: HOST_IP environment variable is required"
  exit 1
fi

# Create the /etc/redis directory if it doesn't exist
mkdir -p /etc/redis

# Generate the sentinel.conf file
cat <<EOF > /etc/redis/sentinel.conf
port ${redis_sentinel_port}
sentinel monitor ${redis_sentinel_leader_name} $${HOST_IP} ${redis_port+1} 1
%{if (redis_password != null && redis_password != "") && (redis_username == null || redis_username == "")}
sentinel auth-pass ${redis_sentinel_leader_name} ${redis_password}
%{endif}
%{if (redis_password != null && redis_password != "") && (redis_username != null && redis_username != "")}
sentinel auth-pass ${redis_sentinel_leader_name} ${redis_password}
sentinel auth-user ${redis_sentinel_leader_name} ${redis_username}
%{endif}
sentinel resolve-hostnames yes
sentinel down-after-milliseconds ${redis_sentinel_leader_name} 5000
sentinel failover-timeout ${redis_sentinel_leader_name} 10000
sentinel parallel-syncs ${redis_sentinel_leader_name} 1
user ${redis_sentinel_username} on >${redis_sentinel_password} ~* &* +@all
requirepass adminPassword
daemonize no
logfile ""
logfile /dev/stdout
EOF

# Start Redis Sentinel in the foreground
exec redis-server /etc/redis/sentinel.conf --sentinel
