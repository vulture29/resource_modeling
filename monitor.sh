#!/bin/bash

while true
do 
    cpu_usage=$(top -b -d1 -n1 | grep httpd | awk '{sum += $9} END {print sum}')
    curr_time=$(date +%s)
    line="$curr_time,$cpu_usage"
    echo $line >> ~/cpu_usage_data
    sleep 2
done