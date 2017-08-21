#!/bin/bash -e

touch /data/setup.log
echo '' > /data/setup.log

echo '-----------setup1.sh------------' >> /data/setup.log

#lines following is to try to remove the 'dpkg-preconfigure: unable to re-open stdin: No such file or directory' error
echo "pre-setting of locals " >> /data/setup.log
echo "pre-setting of locals "
sudo locale-gen "en_US.UTF-8"  >> /data/setup.log
sudo locale-gen "fr_FR.UTF-8"  >> /data/setup.log
sudo dpkg-reconfigure locales
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo sh -c "echo 'export LC_ALL=\"fr_FR.UTF-8\"' >> ~/.bashrc"  >> /data/setup.log
source ~/.bashrc


message='Updating packages'
echo $message
echo $message >> /data/setup.log
sudo apt-get -q update >> /data/setup.log
sudo apt-get -q upgrade >> /data/setup.log

message='installing first dependencies (java, python, postresg)'
echo $message
echo $message >> /data/setup.log
#install backend dependencies
sudo apt-get install build-essential -y >> /data/setup.log
sudo apt install openjdk-8-jre-headless -y >> /data/setup.log
sudo apt install git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev -y  >> /data/setup.log
sudo apt-get install postgresql-9.5 postgresql-contrib-9.5 postgresql-client-common -y  >> /data/setup.log
sudo apt-get install postgresql-9.5-postgis-2.2 -y >> /data/setup.log

message='initialisation of the user osmose'
echo $message
echo $message >> /data/setup.log
sudo useradd -m -c "osmose" osmose  -s /bin/bash  >> /data/setup.log
sudo adduser osmose ubuntu  >> /data/setup.log
sudo sed -i.bak 's/[#]*umask[ ]*[\t]*022/umask 002/' /home/osmose/.profile
touch ~/.pgpass
echo "localhost:5432:*:osmose:-osmose-" >> ~/.pgpass
sudo chmod 600 ~/.pgpass
# allow connection to localhost via unix socket
sudo sed -i -e "s/local   all             all                                     peer/local   all             all                                     md5/g" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i -e "s/host    all             all             127.0.0.1\/32            md5/host    all             all                 0.0.0.0\/0                   md5/g" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i -e "s/.*listen_addresses =.*/listen_addresses = '*'/g" /etc/postgresql/9.5/main/postgresql.conf
sudo service postgresql reload


message='initialisation of the backend database'
echo $message
echo $message >> /data/setup.log
sudo service postgresql restart  >> /data/setup.log
sudo -u postgres psql -c "CREATE USER osmose WITH PASSWORD '-osmose-';"  >> /data/setup.log
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose;"  >> /data/setup.log
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension fuzzystrmatch; CREATE extension unaccent; CREATE extension postgis;" osmose >> /data/setup.log
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE ON TABLE spatial_ref_sys TO osmose;" osmose >> /data/setup.log
sudo -u postgres psql -c "GRANT SELECT,UPDATE,DELETE,INSERT ON TABLE geometry_columns TO osmose;" osmose >> /data/setup.log


#Changind umask of user vagrant to fix issue with cache file write protection
# sudo sed -i.bak 's/[#]*umask[ ]*[\t]*022/umask 002/' /home/ubuntu/.profile
# source /home/ubuntu/.profile
