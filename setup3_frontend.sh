#!/bin/bash -e

echo '-----------setup3_frontend.sh------------' >> /data/setup.log
echo '-----------setup3_frontend.sh------------'

echo "Downloading frontend from GitHub"  >> /data/setup.log
echo "Downloading frontend from GitHub"
rm -rf /data/frontend
mkdir -p /data/frontend
git clone https://github.com/osm-fr/osmose-frontend /data/frontend
cd /data/frontend

echo "Creation of the frontend database" >> /data/setup.log
echo "Creation of the frontend database"
sudo -u postgres bash -c "createdb -E UTF8 -T template0 -O osmose osmose_frontend;"  >> /data/setup.log
sudo -u postgres psql -c "CREATE extension hstore; CREATE extension postgis;" osmose_frontend  >> /data/setup.log
psql -h localhost -U osmose -d osmose_frontend -f /data/frontend/tools/database/schema.sql  >> /data/setup.log
psql -h localhost -U osmose -d osmose_frontend -f /data/frontend/tools/database/18_add_version_on_update_last.sql  >> /data/setup.log


echo "Installing virtualenv dependencies" >> /data/setup.log
echo "Installing virtualenv dependencies"
virtualenv --python=python2.7 osmose-frontend-venv
source osmose-frontend-venv/bin/activate
sudo apt-get install pkg-config libfreetype6-dev -y >> /data/setup.log
sudo apt-get install libjpeg-dev -y  >> /data/setup.log
pip install requests beaker bottle-beaker  >> /data/setup.log
pip install rauth >> /data/setup.log
pip install freetype-py  >> /data/setup.log
echo 'installing numpy' >> /data/setup.log
echo 'installing numpy'
pip install numpy >> /data/setup.log
#PIL in requirements is replaced by pillow
sudo sed -i.bak '/PIL/d' requirements.txt  >> /data/setup.log
echo 'installing requirements.txt' >> /data/setup.log
echo 'installing requirements.txt'
pip install -r requirements.txt  --allow-all-external  >> /data/setup.log
echo 'installing pillow' >> /data/setup.log
echo 'installing pillow'
pip install pillow  >> /data/setup.log

echo "Configuration of the Apache site" >> /data/setup.log
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

sudo a2dissite 000-default.conf >> /data/setup.log
sudo a2ensite osmose.conf   >> /data/setup.log
sudo a2enmod expires.load  >> /data/setup.log
sudo a2enmod rewrite.load  >> /data/setup.log
sudo service apache2 reload  >> /data/setup.log
mkdir -p /data/work/export


echo "Generating mo files" >> /data/setup.log
echo "Generating mo files"
cd /data/frontend/po && make mo >> /data/setup.log
cd /data/frontend

echo "initialisation of the submodules" >> /data/setup.log
echo "initialisation of the submodules"
git submodule update --init >> /data/setup.log

echo "populating osmose_frontend database with required data" >> /data/setup.log
echo "populating osmose_frontend database with required data"
cd /data
python import_front_dbdata.py 'dynpoi_categ' > /tmp/tmp.sql
psql -h localhost -U osmose -d osmose_frontend -f /tmp/tmp.sql  >> /data/setup.log
python import_front_dbdata.py 'dynpoi_item' > /tmp/tmp.sql
psql -h localhost -U osmose -d osmose_frontend -f /tmp/tmp.sql  >> /data/setup.log
