#!/bin/bash -e

set -x

# get osmose-frontend and create a python virtualenv
rm -rf /data/frontend
mkdir -p /data/frontend
git clone https://github.com/osm-fr/osmose-frontend /data/frontend
cd /data/frontend

virtualenv --python=python2.7 osmose-frontend-venv
. osmose-frontend-venv/bin/activate
sudo apt-get install pkg-config libfreetype6-dev -y
sudo apt-get install libjpeg-dev -y
pip install requests beaker bottle-beaker
pip install rauth
pip install freetype-py
pip install numpy
#PIL in requirements is replaced by pillow
sudo sed -i.bak '/PIL/d' requirements.txt
pip install -r requirements.txt  --allow-all-external
pip install pillow

sudo adduser osmose vagrant

#initialisation of the database (creation is done in the setup.sh)
sudo sh -c "echo 'export LC_ALL=\"fr_FR.UTF-8\"' >> ~/.bashrc"
sudo locale-gen "en_US.UTF-8"
sudo locale-gen "fr_FR.UTF-8"
source ~/.bashrc
psql -h localhost -f tools/database/schema.sql osmose_frontend osmose

mkdir -p /data/work/export

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

sudo a2dissite 000-default.conf
sudo a2ensite osmose.conf
sudo a2enmod expires.load
sudo a2enmod rewrite.load
sudo service apache2 reload


cd /data/frontend/po && make mo
cd /data/frontend
git submodule update --init

#No need to exec those scripts, DB should be empty on a fresh install
#No need to generate de .poly files or generate-cover
