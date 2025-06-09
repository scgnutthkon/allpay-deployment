#!/bin/bash

# Configuration
PRIMARY_PORT=5432
REPLICA_PORT=5433
REPLICA_CLUSTER_VERSION=17
REPLICA_CLUSTER_NAME="replica"
PGUSER="postgres"

# Function: Check if a port is listening
is_port_open() {
  nc -z 127.0.0.1 $1 >/dev/null 2>&1
}

# Function: Start the replica if not running
start_replica_cluster() {
  echo "Attempting to start replica cluster..."
  if command -v pg_ctlcluster >/dev/null 2>&1; then
    sudo pg_ctlcluster "$REPLICA_CLUSTER_VERSION" "$REPLICA_CLUSTER_NAME" start
  else
    pg_ctl -D "/var/lib/postgresql/${REPLICA_CLUSTER_VERSION}/${REPLICA_CLUSTER_NAME}" -o "-p $REPLICA_PORT" start
  fi
}

# Step 1: Check if replica is running
if is_port_open $REPLICA_PORT; then
  echo "✅ Replica on port $REPLICA_PORT is running."
else
  echo "❌ Replica on port $REPLICA_PORT is not running."
  start_replica_cluster
  sleep 5
  if is_port_open $REPLICA_PORT; then
    echo "✅ Replica started successfully."
  else
    echo "❌ Failed to start replica. Exiting."
    exit 1
  fi
fi

# Step 2: Get LSNs and compare
PRIMARY_LSN=$(sudo -u $PGUSER psql -p $PRIMARY_PORT -tAc "SELECT pg_current_wal_lsn();" 2>/dev/null)
REPLICA_LSN=$(sudo -u $PGUSER psql -p $REPLICA_PORT -tAc "SELECT pg_last_wal_replay_lsn();" 2>/dev/null)
REPLICA_DELAY=$(sudo -u $PGUSER psql -p $REPLICA_PORT -tAc "SELECT now() - pg_last_xact_replay_timestamp();" 2>/dev/null)

# Step 3: Display results
echo "---------------------------------------"
echo "Primary WAL LSN : $PRIMARY_LSN"
echo "Replica WAL LSN : $REPLICA_LSN"
echo "Replication Delay: $REPLICA_DELAY"
echo "---------------------------------------"

if [ "$PRIMARY_LSN" = "$REPLICA_LSN" ]; then
  echo "✅ Replica is fully synced with primary."
else
  echo "⚠️  Replica is behind the primary."
fi
