#!/bin/bash

if [ -f "/home/zhikangzhang/resource_model/pressure_data" ]; then
  rm /home/zhikangzhang/resource_model/pressure_data
fi

cpu_limit=$1
while true
do 
    cpu_usage=$(top -b -d1 -n1 | grep 3944 | awk '{sum += $9} END {print sum}')
    pressure=$(echo "100 * $cpu_usage / $cpu_limit" | bc)
    echo $pressure >> /home/zhikangzhang/resource_model/pressure_data
    sleep 1
done