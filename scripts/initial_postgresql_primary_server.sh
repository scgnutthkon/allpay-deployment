export https_proxy=http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/
replica_user=replica_user
replica_password=Pay@1234AB!
postgres_password=Pay@1234AB!

sudo apt update

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

sudo apt update

sudo apt install postgresql-17 postgresql-contrib -y

# Configure the primary PostgreSQL instance
sudo bash -c "cat << EOF > /etc/postgresql/17/main/conf.d/override.conf
listen_addresses = '*'
port = '5432'
wal_level = 'replica'
idle_in_transaction_session_timeout = 600000
statement_timeout = 600000
tcp_keepalives_idle = 60       # Time in seconds before sending keepalive
tcp_keepalives_interval = 10  # Time between keepalive messages
tcp_keepalives_count = 5      # Number of failed attempts before closing
max_connections = 3000
idle_session_timeout = 600000
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

sudo systemctl restart postgresql
