#!/bin/bash -e

touch /data/setup.log
echo '' > /data/setup.log

echo '-----------setup1.sh------------' >> /data/setup.log

#lines following is to try to remove the 'dpkg-preconfigure: unable to re-open stdin: No such file or directory' error
echo "pre-setting of locals " >> /data/setup.log
echo "pre-setting of locals "
sudo locale-gen "en_US.UTF-8"  >> /data/setup.log
sudo locale-gen "fr_FR.UTF-8"  >> /data/setup.log
dpkg-reconfigure locales
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo sh -c "echo 'export LC_ALL=\"fr_FR.UTF-8\"' >> ~/.bashrc"  >> /data/setup.log
source ~/.bashrc


echo 'installing first dependencies (java, python, postresg)'
echo 'installing first dependencies (java, python, postresg)' >> /data/setup.log
sudo apt-get -q update >> /data/setup.log
#install backend dependencies
sudo apt install openjdk-7-jre-headless -y >> /data/setup.log

sudo apt install git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev -y  >> /data/setup.log
sudo apt-get install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgresql-client-common -y  >> /data/setup.log


echo 'initialisation of the user osmose'
sudo useradd -m -c "osmose" osmose  -s /bin/bash  >> /data/setup.log
sudo adduser osmose vagrant  >> /data/setup.log
sudo sed -i.bak 's/[#]*umask[ ]*[\t]*022/umask 002/' /home/osmose/.profile
touch ~/.pgpass
echo "localhost:5432:*:osmose:-osmose-" >> ~/.pgpass
sudo chmod 600 ~/.pgpass
# allow connection to localhost via unix socket
sudo sed -i -e "s/local   all             all                                     peer/local   all             all                                     md5/g" pg_hba.conf
sudo /etc/init.d/postgresql reload



echo 'initialisation of the backend database'
sudo /etc/init.d/postgresql restart  >> /data/setup.log
sudo -u postgres psql -c "CREATE USER osmose WITH PASSWORD '-osmose-';"  >> /data/setup.log
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose;"  >> /data/setup.log
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension fuzzystrmatch; CREATE extension unaccent; CREATE extension postgis;" osmose >> /data/setup.log
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE ON TABLE spatial_ref_sys TO osmose;" osmose >> /data/setup.log
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE,INSERT ON TABLE geometry_columns TO osmose;" osmose >> /data/setup.log


#Changind umask of user vagrant to fix issue with cache file write protection
sudo sed -i.bak 's/[#]*umask[ ]*[\t]*022/umask 002/' /home/vagrant/.profile
source /home/vagrant/.profile

# ------ initialisation of the apache server and frontend dependencies -------
echo 'initialisation of apache'
sudo apt install apache2 libapache2-mod-wsgi -y   >> /data/setup.log
sudo apt install gettext librsvg2-bin -y  >> /data/setup.log
