# osmose-vagrant

## Presentation
This project aim to ease the initialization of a local virtual machine with a full installation of OpenStreetMap Osmose tool.

**WIP, only backend for the moment.**

## Getting started
### First use of the BackEnd
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
Yet to be done
