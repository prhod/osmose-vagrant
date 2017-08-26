# osmose-vagrant

## Presentation
This project aim to ease the initialization of a local virtual machine with a full installation of OpenStreetMap Osmose tool.
This local virtual machine is for new analysis modules developpment only, and does not intend to be a multi-users instance.

## Installation and first use
To install this virtual machine, here are the steps :
1. install vagrant and the trigger plugin (`vagrant plugin install vagrant-triggers`)
2. Clone this repository and set current directory to local directory
3. run `vagrant up` in your repository
4. run `vagrant ssh` to connect to the virtual machine
5. run one test `bash /data/tests/test_avignon.sh`
6. run `cd /data/ && bash update_frontend_db.sh`
7. Open your favorite browser and go to `http://localhost;8888` !

Frontend and Backend are connected, but only for a limited list of tests.
The activated tests are listed in the `./backend/osmose_config.py` file and configued in the `./setup4_front_back_link.sh` file

Be careful : when accessing vagrant by ssh, the backend virtualenv will be activated and the current directory will be `/data`

## Trouble shouting
### Some items doesn't show properly on frontend
This may be caused by a misconfiguration of the frontend database.
Follow the folling steps :
1. login in your virtual machine (`vagrant ssh`)
2. run `cd /data/ && bash update_frontend_db.sh`

## How to
### How to run a test
To run a test, you need to :
1. login in your virtual machine (`vagrant ssh`)
2. go to the backend dir `cd /data/backend`
3. activate python virtualenv `source osmose-backend-venv/bin/activate`
4. run `python osmose_run.py -h` to see all available commands

Note : Unless you make some configurations, results won't be displayed in the FrontEnd. See next section for visualisation.

Exemple of one analyse run on one country :

`python osmose_run.py --analyser=analyser_osmosis_boundary_administrative --country=france_ile_de_france`

The results are stored in the `/data/work/` directory.

### How to activate visualisation of a new test
To enable the display of BackEnd tests results :
1. Enable the test by changing it's password BackEnd side in `./backend/osmose_config.py`. Replace `xxx` by `vagrant`
2. Enable the receiption of the backend tests results by adding a source in the FrontEnd database
    1. login in your virtual machine (`vagrant ssh`)
    2. run `cd /data/ && bash update_frontend_db.sh`

This will activate the test for all available countries
