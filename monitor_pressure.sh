#!/bin/bash

if [ -f "/home/centos/resource_model/pressure_data" ]; then
  rm /home/centos/resource_model/pressure_data
fi

cpu_limit=$1
while true
do 
    cpu_usage=$(top -b -d1 -n1 | grep webserver | awk '{sum += $9} END {print sum}')
    pressure=$(echo "1000 * $cpu_usage / $cpu_limit" | bc)
    echo $pressure >> /home/centos/resource_model/pressure_data
    sleep 1
done