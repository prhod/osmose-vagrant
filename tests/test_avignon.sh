cd /data/
# wget http://download.geofabrik.de/europe/france/provence-alpes-cote-d-azur-latest.osm.pbf -O /data/provence-alpes-cote-d-azur-latest.osm.pbf

cd /data/tests
/data/backend/osmconvert/osmconvert /data/provence-alpes-cote-d-azur-latest.osm.pbf -B=avignon.poly -o=avignon.pbf

rm /data/work/extracts/france_provence_alpes_cote_d_azur.osm.pbf
mkdir -p /data/work/extracts/
mv /data/tests/avignon.pbf /data/work/extracts/france_provence_alpes_cote_d_azur.osm.pbf
cd /data/backend
source ./osmose-backend-venv/bin/activate
python osmose_run.py --analyser=osmosis_public_transport_stop_position --country=france_provence_alpes_cote_d_azur --skip-download --no-clean
