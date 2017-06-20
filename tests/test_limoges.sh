wget http://download.geofabrik.de/europe/france/limousin-latest.osm.pbf -O /data/limousin-latest.osm.pbf

bash /data/backend/osmconvert/osmconvert /data/limousin-latest.osm.pbf -B=limoges.poly -o=limoges.pbf

rm /data/work/extracts/limousin-latest.osm.pbf
mv limoges.pbf /data/work/extracts/limousin-latest.osm.pbf
cd /data/backend
source ./osmose-backend-venv/bin/activate
python osmose_run.py --analyser=analyser_sax --country=france_limousin --skip-download --no-clean
