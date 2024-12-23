export https_proxy=http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/
replica_user=replica_user
replica_password=Pay@1234AB!
postgres_password=Pay@1234AB!

sudo apt update

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

sudo apt update

sudo apt install postgresql-17 postgresql-contrib -y

sudo cat << EOF > /etc/postgresql/17/main/conf.d/override.conf
listen_addresses = '*'
port = '5432'
wal_level = 'replica'
EOF

echo "host    replication     $replica_user      0.0.0.0/0            md5" >> /etc/postgresql/17/main/pg_hba.conf
echo "host    replication     $replica_user      ::/0            md5" >> /etc/postgresql/17/main/pg_hba.conf
echo "host     all             all             0.0.0.0/0               md5" >> /etc/postgresql/17/main/pg_hba.conf
echo "host     all             all             ::/0                    md5" >> /etc/postgresql/17/main/pg_hba.conf

sudo systemctl enable postgresql
sudo systemctl start postgresql

sudo -u postgres psql -p 5432 -c "ALTER USER postgres WITH PASSWORD '$postgres_password';"
sudo -u postgres psql -p 5432 -c "CREATE ROLE $replica_user WITH REPLICATION LOGIN PASSWORD '$replica_password';"

sudo systemctl restart postgresql
