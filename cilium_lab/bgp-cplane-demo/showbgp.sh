#!/bin/bash
PREFIX="clab-bgp-cplane-demo-"
HOST=$1
if [ -z "$HOST" ]; then 
	echo "Missing argument :defaulting to router0"
	HOST="tor0"
fi
echo "----- $HOST ----"

docker exec -it $PREFIX$HOST vtysh -c 'show bgp ipv4 summary wide'
echo "--"
docker exec -it $PREFIX$HOST vtysh -c 'show bgp ipv4 wide'
