#!/bin/bash -e

echo 'installing first dependencies (java, python, postresg)'
sudo apt-get -q update > /dev/null
#install backend dependencies
sudo apt install openjdk-7-jre-headless -y > /dev/null

sudo apt install git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev -y > /dev/null
sudo apt-get install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgresql-client-common -y > /dev/null


echo 'initialisation of the user osmose'
sudo useradd -m -c "osmose" osmose  -s /bin/bash
sudo adduser osmose vagrant
touch ~/.pgpass
echo "localhost:5432:*:osmose:-osmose-" >> ~/.pgpass
sudo chmod 600 ~/.pgpass
# allow connection to localhost via unix socket
#sudo sed -i -e "s/local   all             all                                     peer/local   all             all                                     md5/g" pg_hba.conf
#sudo /etc/init.d/postgresql reload

# ----- initialisation of the database ------
echo 'initialisation of the database'
sudo /etc/init.d/postgresql restart
# creation of backend database and access
sudo -u postgres psql -c "CREATE USER osmose WITH PASSWORD '-osmose-';"
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose;"
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension fuzzystrmatch; CREATE extension unaccent; CREATE extension postgis;" osmose
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE ON TABLE spatial_ref_sys TO osmose;" osmose
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE,INSERT ON TABLE geometry_columns TO osmose;" osmose


#Changind umask of user vagrant to fix issue with cache file write protection
sudo sed -i.bak 's/[#]*umask[ ]*[\t]*022/umask 002/' /home/osmose/.profile
cd /home/osmose
source .profile

# ------ initialisation of the apache server and frontend dependencies -------
echo 'initialisation of apache'
sudo apt install apache2 libapache2-mod-wsgi -y  > /dev/null
sudo apt install gettext librsvg2-bin -y > /dev/null
