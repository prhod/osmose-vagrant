wget http://download.geofabrik.de/europe/france/provence-alpes-cote-d-azur-latest.osm.pbf -O /data/provence-alpes-cote-d-azur-latest.osm.pbf

bash /data/backend/osmconvert/osmconvert /data/provence-alpes-cote-d-azur-latest.osm.pbf -B=avignon.poly -o=avignon.pbf

rm /data/work/extracts/france_provence_alpes_cote_d_azur.osm.pbf
mv avignon.pbf /data/work/extracts/france_provence_alpes_cote_d_azur.osm.pbf
cd /data/backend
source ./osmose-backend-venv/bin/activate
python osmose_run.py --analyser=analyser_sax --country=france_provence_alpes_cote_d_azur --skip-download --no-clean
