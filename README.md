# osmose-vagrant

## Presentation
This project aim to ease the initialization of a local virtual machine with a full installation of OpenStreetMap Osmose tool.

**WIP, only backend for the moment.**

## Getting started
### First use of the BackEnd
Note : Unless you make some configurations, results won't be displayed in the FrontEnd. See next section for visualisation.
Setps to launch a backend tests batch :
1. install vagrant
2. Clone this repository
3. run `vagrant up` in your repository
4. run `vagrant ssh`
5. go to the backend dir `cd /data/backend`
6. activate python virtualenv `source osmose-backend-venv/bin/activate`
7. run `python osmose_run.py -h` to see all available commands

Exemple of one analyse run on one country :

`python osmose_run.py --analyser=analyser_osmosis_boundary_administrative --country=france_ile_de_france`

The results are stored in the `/data/work/` directory.

TODO : Check how to clean up archives and database using `backend/tools/cron.sh`

### First use of the FrontEnd
The FrontEnd is available at http://localhost:8888.
To enable the display of BackEnd tests results :
1. Enable the test by changing it's password BackEnd side in `./backend/osmose_config.py`. Replace `xxx` by `your_key`
2. Enable the receiption of the backend tests results by adding a source in the FrontEnd database
    * connect to the database : `psql -h localhost -U osmose -d osmose_frontent`
    * add the type of test : `insert into sources values (1, '_country_', '_analyser_')`. Note that the _analyser_ shound NOT start with "analyser_"
    * add the backend password to this source : `insert into source_password values (1, 'your_key')`
    * quit psql using `\q`
