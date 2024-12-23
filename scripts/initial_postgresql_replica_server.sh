export https_proxy=http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/
replica_user=replica_user
replica_password=Pay@1234AB!
primary_host=10.101.3.156

sudo apt update

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

sudo apt update

sudo apt install postgresql-17 postgresql-contrib -y

sudo cat << EOF > /etc/postgresql/17/main/conf.d/override.conf
listen_addresses = '*'
port = '5432'
EOF

echo "host     all             all             0.0.0.0/0               md5" >> /etc/postgresql/17/main/pg_hba.conf
echo "host     all             all             ::/0                    md5" >> /etc/postgresql/17/main/pg_hba.conf

sudo systemctl enable postgresql
sudo systemctl stop postgresql

sudo rm -rf /var/lib/postgresql/17/main/*

PGPASSWORD="$replica_password" sudo pg_basebackup -h $primary_host -U $replica_user -X stream -C -S replica_1 -v -R -W -D /var/lib/postgresql/17/main/

sudo chown -R postgres:postgres /var/lib/postgresql/17/main

sudo systemctl start postgresql
