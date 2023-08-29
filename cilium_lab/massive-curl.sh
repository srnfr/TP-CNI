#!/bin/bash

TARGET=172.18.0.5
PORT=30760

for i in {1..100}; do 
	curl -s $TARGET:$PORT | egrep '(hostname|Requesting)' ; 
	echo "--" ; 
done

