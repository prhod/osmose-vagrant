#!/bin/bash -e

echo '-----------setup4_front_back_link.sh------------' >> /data/setup.log
echo '-----------setup4_front_back_link.sh------------'

echo "activation of backend analysers" >> /data/setup.log
echo "activation of backend analysers"
sudo sed -i.bak 's/.*self.analyser\["sax"\].*/        self.analyser\["sax"\] = "vagrant"/g' /data/backend/osmose_config.py
sudo sed -i.bak 's/.*self.analyser\["osmosis_relation_public_transport"\].*/        self.analyser\["osmosis_relation_public_transport"\] = "vagrant"/g' /data/backend/osmose_config.py

sudo sed -i.bak 's/.*france_local_db.analyser\["merge_public_transport_FR_ratp"\].*/france_local_db.analyser\["merge_public_transport_FR_ratp"\] = "vagrant"/g' /data/backend/osmose_config.py
sudo sed -i.bak 's/.*france_local_db.analyser\["merge_public_transport_FR_stif"\].*/france_local_db.analyser\["merge_public_transport_FR_stif"\] = "vagrant"/g' /data/backend/osmose_config.py
sudo sed -i.bak 's/.*france_local_db.analyser\["merge_public_transport_FR_transgironde"\].*/france_local_db.analyser\["merge_public_transport_FR_transgironde"\] = "vagrant"/g' /data/backend/osmose_config.py

echo "populate the source and source_password tables of osmose_frontend database" >> /data/setup.log
echo "populate the source and source_password tables of osmose_frontend database"
source /data/backend/osmose-backend-venv/bin/activate
cd /data/frontend/tools
python update-passwords.py  >> /data/setup.log
