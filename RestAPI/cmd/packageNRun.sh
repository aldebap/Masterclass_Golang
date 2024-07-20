#!	/usr/bin/ksh

docker build --tag impactarestapi --file Dockerfile .

docker-compose --file docker-compose.yml up
