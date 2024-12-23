#!/bin/bash

# Set environment variables
export https_proxy="http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/"
replica_user="replica_user"
replica_password="Pay@1234AB!"
replica_port=5433
postgres_password="Pay@1234AB!" # Set this to your desired password
primary_host="127.0.0.1" # Replace with the primary server's IP or hostname

# Update package lists
sudo apt update

# Add PostgreSQL repository
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

# Install PostgreSQL 17 and necessary extensions
sudo apt update
sudo apt install -y postgresql-17 postgresql-contrib

# Configure the primary PostgreSQL instance
sudo bash -c "cat << EOF > /etc/postgresql/17/main/conf.d/override.conf
listen_addresses = '*'
port = '5432'
wal_level = 'replica'
EOF"

# Update `pg_hba.conf` for the primary
sudo bash -c "cat << EOF >> /etc/postgresql/17/main/pg_hba.conf
host    replication     $replica_user      0.0.0.0/0            md5
host    replication     $replica_user      ::/0                 md5
host    all             all                0.0.0.0/0            md5
host    all             all                ::/0                 md5
EOF"

# Enable and start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Set the password for the default postgres user and create a replication user
sudo -u postgres psql -p 5432 -c "ALTER USER postgres WITH PASSWORD '$postgres_password';"
sudo -u postgres psql -p 5432 -c "CREATE ROLE $replica_user WITH REPLICATION LOGIN PASSWORD '$replica_password';"

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

############## Create Replica ##########################

# Create a new PostgreSQL cluster for the replica
sudo pg_createcluster 17 replica --port=$replica_port

# Configure the replica PostgreSQL instance
sudo bash -c "cat << EOF > /etc/postgresql/17/replica/conf.d/override.conf
listen_addresses = '*'
port = '$replica_port'
EOF"

# Update `pg_hba.conf` for the replica
sudo bash -c "cat << EOF >> /etc/postgresql/17/replica/pg_hba.conf
host    all             all                0.0.0.0/0            md5
host    all             all                ::/0                 md5
EOF"

# Enable PostgreSQL service
sudo systemctl enable postgresql

# Clean up the replica data directory
sudo rm -rf /var/lib/postgresql/17/replica/*

# Perform a base backup from the primary
PGPASSWORD="$replica_password" sudo -u postgres pg_basebackup -h "$primary_host" -U "$replica_user" -X stream -C -S replica_1 -v -R -D /var/lib/postgresql/17/replica/

# Set proper ownership for the replica directory
sudo chown -R postgres:postgres /var/lib/postgresql/17/replica

# Restart PostgreSQL to finalize setup
sudo systemctl restart postgresql
