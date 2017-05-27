#!/bin/bash -e

set -x

# get osmose-frontend and create a python virtualenv
rm -rf /data/frontend
mkdir -p /data/frontend
git clone https://github.com/osm-fr/osmose-frontend /data/frontend
cd /data/frontend

deactivate
virtualenv --python=python2.7 osmose-frontend-venv
. osmose-frontend-venv/bin/activate
pip install -r requirements.txt  --allow-all-external -y
pip install pillow -y

#initialisation of the database (creation is done in the setup.sh)
psql osmose_frontend -f tools/database/schema.sql

mkdir -p /data/work/osmose/export

sudo cp /data/frontend/apache-site /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/.*ServerName .*/\tServerName osmose.vagrant.local/' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/ServerAlias /d' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/data\/project\/osmose\/frontend/data\/frontend/' /etc/apache2/sites-available/osmose.conf
sudo sed -i.bak 's/.*WSGIDaemonProcess .*/\tWSGIDaemonProcess osmose processes=2 threads=15 user=osmose group=osmose python-home=\/data\/frontend\/osmose-frontend-venv\//' /etc/apache2/sites-available/osmose.conf
# modification of tools/utils.py
sudo sed -i.bak 's/.*website .*"osmose.openstreetmap.fr"/website = "osmose.vagrant.local"/' /data/frontend/tools/utils.py
sudo sed -i.bak 's/dir_results .*/dir_results = "\/data\/work\/results"/' /data/frontend/tools/utils.py

sudo a2dissite 000-default.conf
sudo a2ensite osmose.conf
sudo a2enmod expires.load
sudo a2enmod rewrite.load
sudo service apache2 reload


cd /data/frontend/po && make mo
cd /data/frontend
git submodule update --init
