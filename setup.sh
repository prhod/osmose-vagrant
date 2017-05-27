#!/bin/bash -e

set -x

whoami
sudo apt-get -q update
#install backend dependencies
sudo apt install openjdk-7-jre-headless -y

sudo apt install git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev -y
sudo apt-get install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgresql-client-common -y

sudo /etc/init.d/postgresql restart

# creation of backend database and access
sudo -u postgres psql -c "CREATE USER osmose WITH PASSWORD '-osmose-';"
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose;"
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension fuzzystrmatch; CREATE extension unaccent; CREATE extension postgis;" osmose
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE ON TABLE spatial_ref_sys TO osmose;" osmose
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE,INSERT ON TABLE geometry_columns TO osmose;" osmose
touch ~/.pgpass
echo "localhost:5432:*:osmose:-osmose-" >> ~/.pgpass
