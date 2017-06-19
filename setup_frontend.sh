#!/bin/bash -e

echo "Downloading frontend from GitHub and creating python virtualenv"
rm -rf /data/frontend
mkdir -p /data/frontend
git clone https://github.com/osm-fr/osmose-frontend /data/frontend
cd /data/frontend

echo "Creation of the frontend database"
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose_frontend;"  > /dev/null
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension postgis;" osmose_frontend  > /dev/null
psql -h localhost -U osmose -d osmose_frontend -f /data/frontend/tools/database/schema.sql  > /dev/null
psql -h localhost -U osmose -d osmose_frontend -f /data/frontend/tools/database/18_add_version_on_update_last.sql  > /dev/null


echo "Installing virtualenv dependencies"
virtualenv --python=python2.7 osmose-frontend-venv
. osmose-frontend-venv/bin/activate
sudo apt-get install pkg-config libfreetype6-dev -y  > /dev/null
sudo apt-get install libjpeg-dev -y  > /dev/null
pip install requests beaker bottle-beaker  > /dev/null
pip install rauth  > /dev/null
pip install freetype-py  > /dev/null
echo 'installing numpy'
pip install numpy > /dev/null
#PIL in requirements is replaced by pillow
sudo sed -i.bak '/PIL/d' requirements.txt  > /dev/null
echo 'installing requirements.txt'
pip install -r requirements.txt  --allow-all-external  > /dev/null
echo 'installing pillow'
pip install pillow  > /dev/null

echo "Initialisation of the database (creation is done in the setup.sh)"
sudo sh -c "echo 'export LC_ALL=\"fr_FR.UTF-8\"' >> ~/.bashrc"  > /dev/null
sudo locale-gen "en_US.UTF-8"  > /dev/null
sudo locale-gen "fr_FR.UTF-8"  > /dev/null
source ~/.bashrc
mkdir -p /data/work/export

echo "Configuration of the Apache site"
sudo cp /data/frontend/apache-site /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/.*ServerName .*/\tServerName osmose.vagrant.local/' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak '/ServerAlias /d' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/data\/project\/osmose/data/g' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/data\/work\/osmose\/export/data\/work\/export/g' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/.*WSGIDaemonProcess .*/\tWSGIDaemonProcess osmose processes=2 threads=15 user=osmose group=osmose python-home=\/data\/frontend\/osmose-frontend-venv\//' /etc/apache2/sites-available/osmose.conf
# modification of tools/utils.py
sudo sed -i.bak 's/.*website .*"osmose.openstreetmap.fr"/website = "localhost:8888"/' /data/frontend/tools/utils.py
sudo sed -i.bak 's/dir_results .*/dir_results = "\/data\/work\/results"/' /data/frontend/tools/utils.py

# modification of the backend configuration with the frontend config (with Vagrant internal http port)
sudo sed -i.bak 's/http:\/\/osmose.openstreetmap.fr/http:\/\/localhost:80/' /data/backend/modules/config.py
sudo sed -i.bak 's/http:\/\/opendata.osmose.openstreetmap.fr/http:\/\/localhost:80/' /data/backend/modules/config.py

sudo a2dissite 000-default.conf  > /dev/null
sudo a2ensite osmose.conf   > /dev/null
sudo a2enmod expires.load  > /dev/null
sudo a2enmod rewrite.load  > /dev/null
sudo service apache2 reload  > /dev/null


cd /data/frontend/po && make mo  > /dev/null
cd /data/frontend
git submodule update --init > /dev/null

#populating osmose_frontend database with required data
cd /data
python import_front_dbdata.py 'dynpoi_categ' > /tmp/tmp.sql
psql -h localhost -U osmose -d osmose_frontend -f /tmp/tmp.sql > /dev/null
python import_front_dbdata.py 'dynpoi_item' > /tmp/tmp.sql
psql -h localhost -U osmose -d osmose_frontend -f /tmp/tmp.sql > /dev/null
