#!/bin/bash

for n in $(doctl compute domain records list randco.eu | egrep "groupe[0-9]" | cut -f1,2 -d' '); do
	echo "doctl compute domain records delete randco.eu ${n} --force";
	doctl compute domain records delete randco.eu ${n} --force;
done;
