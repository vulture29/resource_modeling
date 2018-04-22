#!/bin/bash

if [ -f "~/resource_model/pressure_data" ]; then
  rm /home/zhikangzhang/resource_model/pressure_data
fi

monitor_pid="3944"
cpu_limit=$1
while true
do 
    cpu_usage=$(top -b -d1 -n1 | grep $monitor_pid | awk '{sum += $9} END {print sum}')
    pressure=$(echo "100 * $cpu_usage / $cpu_limit" | bc)
    echo $pressure >> ~/resource_model/pressure_data
    sleep 1
done