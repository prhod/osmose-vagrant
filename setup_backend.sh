#!/bin/bash -e

echo "get osmose-backend and create a python virtualenv"
rm -rf /data/backend
mkdir -p /data/backend
git clone https://github.com/osm-fr/osmose-backend /data/backend
cd /data/backend
virtualenv --python=python2.7 osmose-backend-venv
. osmose-backend-venv/bin/activate
pip install -r requirements.txt  > /dev/null
pip install -r requirements-dev.txt > /dev/null

cd /data/backend/modules/
sed -i.bak 's/dir_work = .*/dir_work = "\/data\/work\/"/' config.py
cd /data/backend/
sed -i.bak 's/db_host     = None/db_host = "localhost"/' osmose_config.py
