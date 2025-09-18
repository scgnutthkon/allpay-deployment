replica_user=replica_user
replica_password=Pay@1234AB!
primary_host=10.101.3.156
replica_port=5432

proxyUrl="http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/"
proxyEsp=$(echo $proxyUrl | sed s/%/%%/g)

export http_proxy="$proxyUrl"
export https_proxy="$proxyUrl"
export ftp_proxy="$proxyUrl"
export no_proxy=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.scg.com,.scg-mpc.hpe.com

sudo apt update
sudo apt install postgresql-common
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

sudo apt update

sudo apt install postgresql-17 postgresql-contrib -y

sudo pg_createcluster 17 main --start


# Configure the replica PostgreSQL instance
sudo bash -c "cat << EOF > /etc/postgresql/17/main/conf.d/override.conf
listen_addresses = '*'
port = '$replica_port'
idle_in_transaction_session_timeout = 600000
statement_timeout = 600000
tcp_keepalives_idle = 60       # Time in seconds before sending keepalive
tcp_keepalives_interval = 10  # Time between keepalive messages
tcp_keepalives_count = 5      # Number of failed attempts before closing
max_connections = 3000
idle_session_timeout = 600000
EOF"

# Update `pg_hba.conf` for the replica
sudo bash -c "cat << EOF >> /etc/postgresql/17/main/pg_hba.conf
host    all             all                0.0.0.0/0            md5
host    all             all                ::/0                 md5
EOF"

# Enable PostgreSQL service
sudo systemctl enable postgresql

# Clean up the replica data directory
sudo rm -rv /var/lib/postgresql/17/main

# Perform a base backup from the primary
PGPASSWORD="$replica_password" sudo -u postgres pg_basebackup -h "$primary_host" -U "$replica_user" -X stream -C -S replica_2 -v -R -D /var/lib/postgresql/17/main/

# Set proper ownership for the replica directory
sudo chown -R postgres:postgres /var/lib/postgresql/17/main

sudo pg_ctlcluster 17 main restart

# Restart PostgreSQL to finalize setup
sudo systemctl restart postgresql
