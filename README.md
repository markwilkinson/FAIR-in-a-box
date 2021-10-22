# temp-cde-in-a-box
an alternative cde in a box installation process vs. Rajaram's.  Just testing for the moment

CDE in a box` is a collection of software applications which enables creation, storing and publishing of "Common Data Elements" according to the [CDE semantic model](https://github.com/ejp-rd-vp/CDE-semantic-model).

## CONTENTS

* [Installation requirements](#requirements)
* [Downloading](#downloading)
* [Installing](#installing)
* [Testing your installation](#testing)
* [Using your CDE-in-a-Box](#using)

<a name="requirements"></a>

## Requirements
In order to use the cde-in-box solution you `have to` meet following requirements.

**User requirements (Person who is deploying this solution)**

* Basic knowledge about Docker​
* Basic GitHub knowledge​
* Awareness of CDE semantic model

**System requirements​ (Machine where this solution is being deployed)**

* Docker engine ​
* Docker-compose application​

---------------------------------------------------

<a name="downloading"></a>

## Downloading

#### cde-in-a-box

To get the CDE in a box code clone this repository to your machine.

```sh
git clone https://github.com/ejp-rd-vp/cde-in-box
```

#### GraphDB

To use CDE-in-a-box you also need to download the *standalone* graphDB triple store free edition. Follow the steps below to get free edition of graphdb.


**Step 1:** GO to this [url](https://www.ontotext.com/products/graphdb/graphdb-free/) and register to download GraphDB free edition.


**Step 2:** The download link will be sent to your email. From the email follow link to download page and `click` on _"Download as a stand-alone server"_. This step will download "graphdb-free-{version}-dist.zip" file to your machine.


**Step 3:** Move "graphdb-free-{version}-dist.zip" file to the following location

```sh
mv graphdb-free-{version}-dist.zip cde-in-box/bootstrap/graph-db
```

**Step 4:** If your `graphdb version` is different from `9.9.1` then change the version number of graph DB in the ./cde-in-box/bootstrap/docker-compose file.

```sh
graph_db:
    build:
      context: ./graph-db
      dockerfile: Dockerfile        
      args:
        version: 9.7.0
```

**Step 5:** If your `graphdb version` is different from `9.9.1` then change the version number of graph DB in the ./cde-in-box/bootstrap/graph-db/Docker file

```sh
FROM adoptopenjdk/openjdk11:alpine

# Build time arguments
ARG version=9.9.1
ARG edition=free

```

------------------------------------------------------

<a name="installing"></a>

## Installing

Once you have done above downloads and configurations you can run "run-me-to-install.sh" in the ./cde-in-box/ folder

```sh
./run-me-to-install.sh
```

after several mimnutes, the installer will send a message to the screen asking you to check that the installation was successful.  This message will last for 10 minutes, giving you enough time to explore the links below.  After 10 minutes, the services will all automatically shut down.  You can stop the installer by CTRL-C anytime.

--------------------------------------------------

<a name="testing"></a>

## Testing your installation 

* If the **GraphDB** deployment is successful then you can access GraphDB by visiting the following URL.

**Note:** If you deploy the `CDE in a box` solution in your laptop then check only for **local deployment** url.

| Service name | Local deployment | Production deployment |
| --- | --- | --- |
| GraphDB | [http://localhost:7200](http://localhost:7200/) | http://SERVER-IP:7200 |

By default GraphDB service is secured so you need credentials to login to the graphDB. Please find the default graphDB's credentials in the table below.

| Username| Password |
| --- | --- |
| `admin` | `root` |



* If the **FAIR Data Point** deployment is successful then you can access the FAIR Data Point by visiting the following URL.

| Service name | Local deployment | Production deployment |
| --- | --- | --- |
| FAIR Data Point | [http://localhost:8080](http://localhost:8080) | http://SERVER-IP:8080 |

**Note:** If you deploy the `CDE in a box` solution in your laptop then check only for **local deployment** url.

In order to add content to the FAIR Data Point you need credentials with write access. Please find the default FAIR Data Point's credentials in the table below.

| Username| Password |
| --- | --- |
| `albert.einstein@example.com` | `password` |


-----------------------------------------------------


<a name="using"></a>

# Using CDE-in-a-box for data transformation

In the folder ./cde-ready-to-go there is a docker-compose.yml file, and two directories.  You may move these files/folders anywhere on your system, once you have completed the installation and testing described above (the installation files, including the graphdb zip, may be deleted if you no longer want to keep them)

the folder structure is:
```
.--
  | docker-compose.yml
  | /data
  ---
    | /triples
  | /config
  
```
* The /data folder contains CSV, with each CSV file representing one of the CDEs.
* The /config folder contains [YARRRML Templates](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/YARRRML_Transform_Templates), one for each of the CSVs.

#### Preparing input data

The transformation services take `CSV` as input files. We provide `CSVs` with example data and `YARRRML` templates for each CDE module [here](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/YARRRML_Transform_Templates).
The `YARRRML` templates are always loaded from GitHub automatically, so they stay up-to-date as we change the models in EJP-RD, but the `CSV` files must be added by the user.


#### Configuring configuration and data folders 


**Step 1:** Folder structure

Make sure the following folder structure, relative to where you plan to keep your pre and post-transformed data, is available:
```
        .
        .cde-ready-to-go/data/   
        .cde-ready-to-go/data/mydataX.csv  (input csv files, e.g. "height.csv")
        .cde-ready-to-go/data/mydataY.csv...
        .cde-ready-to-go/config/   (this is the folder where yarrrml templates will be automatically loaded from the EJP repository)
``` 
**Step 2:**  Edit the .env file

the .env file will create the values for the environment variables in the docker compose file.  The first of these `baseURI` is the base for all URLs that represent your transformed data.  This should be set to something like:

`http://my.database.org/my_rd_data/`

this will result in Triple that look like this:

`<http://my.database.org/my_rd_data/person_123345_asdssaewe#ID>  <sio:has-value>  <"123345">`

optimally, these URLs will resolve...

**Step 3:**  Running data transformation services

Then you can run the data transformation services setup by running the `docker-compose.yml` file in `cde-in-box/cde-ready-to-go` directory.  Be sure that you move this into the appropriate location; **THE docker-compose MUST BE RUN IN THE SAME FOLDER THAT CONTAINS THE ./data/triples and ./config and subfolders**

You should then refresh your local copies of the docker images, to ensure they are up-to-date with what EJP is providing:

```
docker-compose pull
```  
followed by:

```sh
docker-compose up -d
```


**Step 4:** Input CSV files

Put an appropriately columned `XXXX.csv` into the `cde-in-box/cde-ready-to-go/data`. Please look into [this](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/YARRRML_Transform_Templates) github repository for examples of CDEs `CSV` files.


**Step 5:** Input YARRRML templates

The `YARRRML` templates are always loaded from GitHub automatically on step 5, so they stay up-to-date as we change the models in EJP-RD.

Make sure the `YARRRML` templates files are matching your `CSV` files names `XXXX_yarrrml_template.yaml` and are in the `cde-in-box/cde-ready-to-go/config` folder. Please look into [this](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/YARRRML_Transform_Templates) github repository for CDEs `YARRRML` templates.


**Step 6:**  Executing transformations

Call the url:  http://localhost:4567 or http://SERVER-IP:4567  to trigger the transformation of each CSV file, and auto-load into graphDB (this will over-write what is currrently loaded!  We will make this behaviour more flexible later)
**Note:** If you deploy `CDE in a box` solution in your laptop then check only for **localhost** url.

**There is sample data (height.csv) in the "cde-ready-to-go/data" folder that can be used to test your installation.**


### How to modify semantic model in data transformation service

YARRRML is one the core technology which has been used in our data transformation service. If you like to extend the CDE semantic model or add other semantic model to describe your data then, you have to provide custom YARRRML templates to the data transformation service. To learn more about building custom YARRRML templates please try [matey webapp](https://rml.io/yarrrml/matey/).


<a name="Understanding"></a>
# Understanding your CDE in a box installation

## Software used in CDE in a box
The image below gives an overview of softwares used in the `CDE in a box` solutions.

<p align="center"> 
    <a href="docs/images/components_overview.jpg" target="_blank">
        <img src="docs/images/components_overview.jpg"> 
    </a>
</p>

**Triple store:**
To store the `rdf` documents generated by the `CDE in a box` solution we need to have a triplestore which stores these document. In the `CDE in a box` solution we use graphDB as a triplestore. To know more about the graphDB triplestore please visit this [link](https://graphdb.ontotext.com)

**FAIR Data Point:**
To describe the content of your resource we need a `metadata provider` component. For the `CDE in a box` solution we use `FAIR Data Point` software that provides description (metadata) of you resource. To learn more about the FAIR Data Point please visit this [link](https://fairdatapoint.readthedocs.io/en/latest/)

<a name="Alternatives"></a>
# Alternatives

## Other known CDE​ in a box solutions
In this section we list other known `CDE in a box` solutions.

**MOLGENIS CDE in a box**     
MOLGENIS EDC provider also provides a complete set of `CDE in a box` with EDC system. To learn more about MOLGENIS implementation of the `CDE in a box` solution please visit this [link](https://github.com/fdlk/cde-in-box/tree/feat/molgenis)

