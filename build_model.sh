#!/bin/bash

# check parameters
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 app_name web_host_ip" >&2
  exit 1
fi

# check and delete old file
if [ -f "/home/centos/resource_model/res_data" ]; then
  rm /home/centos/resource_model/res_data
fi

cd /home/centos/RUBiS
app_name=$1
web_host_ip=$2

echo "Start building resource model..."

# control cpu cgroup in the server
for i in {3..9..2}
  do
    echo "Test for performance under cgroup $i..."
    command="
    echo '${i}0000' > /cgroup/cpu/limitcpu/cpu.cfs_quota_us
    cgclassify -g cpu:limitcpu $(pidof $app_name)
    "
    ssh "root@$web_host_ip" "$command" >> /home/centos/resource_model/modeling_remote_log
    
    perf_path=$(make emulator | awk 'NR==4{ print $4 ; exit }')
    slo=$(cat /home/centos/RUBiS/${perf_path}perf.html | grep '<TR><TD><div align=left><B>Total</div></B><TD><div align=right>' | egrep -o [0-9]+ | sed -n '10 p')
    echo "$i $slo" >> /home/centos/resource_model/res_data
  done

# build resource model
cd /home/centos/resource_model
