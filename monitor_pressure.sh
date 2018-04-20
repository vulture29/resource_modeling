#!/bin/bash

if [ -f "/home/centos/resource_model/pressure_data" ]; then
  rm /home/centos/resource_model/pressure_data
fi

pressure=0
cpu_limit=$1
while true
do 
    cpu_usage=$(top -b -d1 -n1 | grep httpd | awk '{sum += $9} END {print sum}')
    new_pressure=$(echo "100 * $cpu_usage / $cpu_limit" | bc)
    echo $new_pressure >> /home/centos/resource_model/pressure_data
    if [ "$new_pressure" -lt "$pressure" ]
      then
        pressure=$new_pressure
      fi
    sleep 1
done