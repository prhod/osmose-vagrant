#!/bin/bash -e

message='-----------setup2_backend.sh------------'
echo $message
echo $message >> /data/setup.log

if [ -e /data/backend ]; then
    echo "/data/backend directory exists. Skipping github clonning."
    echo "/data/backend directory exists. Skipping github clonning." >> /data/setup.log
else
    echo "/data/backend directory does not exists. Installing from osm-fr/master."
    echo "cloning osmose-backend" >> /data/setup.log
    echo "cloning osmose-backend"
    mkdir -p /data/backend
    git clone https://github.com/osm-fr/osmose-backend /data/backend >> /data/setup.log
    echo "Patching Beckend config" >> /data/setup.log
    echo "Patching Beckend config"
    cd /data/backend/modules/
    sed -i.bak 's/dir_work = .*/dir_work = "\/data\/work\/"/' config.py
    cd /data/backend/
    sed -i.bak 's/db_host     = None/db_host = "localhost"/' osmose_config.py
fi

if [ ! -e /data/backend/osmose-backend-venv ]; then
    echo "create backend virtualenv" >> /data/setup.log
    echo "create backend virtualenv"
    cd /data/backend
    virtualenv --python=python2.7 osmose-backend-venv >> /data/setup.log
    . osmose-backend-venv/bin/activate
    echo "installing dependencies (requirements.txt)" >> /data/setup.log
    echo "installing dependencies (requirements.txt)"
    pip install -r requirements.txt  >> /data/setup.log
    echo "installing dependencies (requirements-dev.txt)" >> /data/setup.log
    echo "installing dependencies (requirements-dev.txt)"
    pip install -r requirements-dev.txt >> /data/setup.log
else
    message='/data/backend/osmose-backend-venv exists. Skipping virtualenv creation'
    echo $message
    echo $message >> /data/setup.log
fi
