
#!/bin/bash

docker volume remove -f fdp-client-assets fdp-client-css fdp-client-scss fdp-server mongo mongo-data mongo-init fdp-client


docker volume create fdp-client
docker volume create fdp-server
docker volume create mongo
docker volume create fdp-client-assets
docker volume create fdp-client-scss
docker volume create mongo-data
docker volume create mongo-init

docker-compose up -d
sleep 100
docker-compose down

docker run -v fdp-client:/src/scss/custom/ --name helper busybox true
docker cp ./fdp-client/variables.scss helper:/src/scss/custom/_variables.scss:ro
docker rm helper

docker run -v fdp-client:/usr/share/nginx/html/ --name helper busybox true
docker cp ./fdp-client/assets/ helper:/usr/share/nginx/html/
docker cp ./fdp-client/favicon.ico helper:/usr/share/nginx/html/
docker rm helper

#mkdir data
#docker run -v mongo:/data/db --name helper busybox true

#docker cp data helper:/data/db/
#docker rm helper

docker run -v fdp-client-scss:/src/scss/custom/ --name helper busybox true
docker cp ./fdp-client/variables.scss helper:/src/scss/custom/_variables.scss
docker rm helper

docker run -v fdp-client-assets:/usr/share/nginx/html/ --name helper busybox true
docker cp ./fdp-client/assets/ helper:/usr/share/nginx/html/
docker rm helper

docker run -v mongo-data:/data/db/ --name helper busybox true
docker cp data helper:/data/db
docker rm helper


docker run -v mongo-init:/docker-entrypoint-initdb.d/ --name helper busybox true
docker rm helper 

docker run -v fdp-server:/fdp/ --name helper busybox true
docker cp ./fdp/application.yml helper:/fdp/
docker rm helper

