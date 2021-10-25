
#!/bin/bash

docker volume remove -f fair-data-point fdp-client-assets fdp-client-css fdp-client-scss fdp-server mongo-data mongo-init 

docker volume create fair-data-point

docker volume create fdp-server

#docker volume create fdp-client
docker volume create fdp-client-assets
docker volume create fdp-client-scss

#docker volume create mongo
docker volume create mongo-data
docker volume create mongo-init

GREEN='\033[0;32m'
NC='\033[0m' # No Color
CWD=$(pwd)


function ctrl_c() {
        docker-compose -f $CWD/metadata/docker-compose.yml down
        docker-compose -f $CWD/bootstrap/docker-compose.yml down
        exit 2
}

trap ctrl_c 2


cd bootstrap
echo ""
echo ""
echo -e "${GREEN}Creating GraphDB and bootstrapping it - this will take several minutes"
echo -e "Go make a nice cup of tea and then come back to check on progress"
echo -e "${NC}"
echo ""

docker-compose up -d
sleep 200

echo ""
echo -e "${GREEN}Setting up FAIR Data Point client and server${NC}"
echo ""
cd ../metadata

docker-compose up -d
sleep 200
docker-compose down

docker run -v fdp-server:/fdp/ --name helper busybox true
docker cp ./fdp/application.yml helper:/fdp/
docker rm helper


echo "fdp client css helper"
docker run -v fdp-client-scss:/src/scss/custom/ --name helper busybox true
docker cp ./fdp-client/variables.scss helper:/src/scss/custom/_variables.scss:ro
docker rm helper

echo "fdp client nginx config helper"
docker run -v fdp-client-assets:/usr/share/nginx/html/ --name helper busybox true
docker cp ./fdp-client/assets/ helper:/usr/share/nginx/html/
docker cp ./fdp-client/favicon.ico helper:/usr/share/nginx/html/
docker rm helper

#mkdir data
#docker run -v mongo:/data/db --name helper busybox true

#docker cp data helper:/data/db/
#docker rm helper

#docker run -v mongo-data:/data/db/ --name helper busybox true
#docker cp data helper:/data/db
#docker rm helper


#docker run -v mongo-init:/docker-entrypoint-initdb.d/ --name helper busybox true
#docker rm helper 


echo ""
echo ""
docker-compose up -d
sleep 20
docker-compose down
docker volume remove -f mongo-data
docker volume create mongo-data
docker-compose up -d

echo ""
echo ""
echo -e "${GREEN}Installation Complete!"
echo -e  "${GREEN}you now have 10 minutes to test things."  
echo -e  "${GREEN}If GraphDB is working, you should be able to access it at: http://localhost:7200"
echo -e  "${GREEN}If Your FAIR Data Point is working, you should be able to access it at: http://localhost:8080"
echo ""
echo -e  "${GREEN}For further instructions and tests, read the documentation on the cde-in-a-box GitHub page${NC}"
echo ""
echo -e  "${GREEN}You can stop this test phase at any time with CTRL-C, then wait for the docker images to shut down cleanly before continuing${NC}"
sleep 600
docker-compose down
cd ..

