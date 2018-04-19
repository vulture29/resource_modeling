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
for i in {1..99..0.1}
  do
    echo "Test for performance under cgroup $i..."
    root_command="
    echo 'mount {
            cpuset  = /cgroup/cpuset;
            cpu     = /cgroup/cpu;
            cpuacct = /cgroup/cpuacct;
            memory  = /cgroup/memory;
            devices = /cgroup/devices;
            freezer = /cgroup/freezer;
            net_cls = /cgroup/net_cls;
            blkio   = /cgroup/blkio;
    }

    group limitcpu{
            cpu {
                    cpu.cfs_quota_us = ${i}0000;
                    cpu.cfs_period_us = 1000000;
            }
    }' > /etc/cgconfig.conf
    "
    ssh "root@$web_host_ip" "$root_command" >> /home/centos/resource_model/res_model_log

    user_command="
    sudo service cgconfig restart
    sudo cgclassify -g cpu:limitcpu \$(pidof $app_name)
    "
    ssh "centos@$web_host_ip" "$user_command" >> /home/centos/resource_model/res_model_log

    perf_path=$(make emulator | awk 'NR==4{ print $4 ; exit }')
    slo=$(cat /home/centos/RUBiS/${perf_path}perf.html | grep '<TR><TD><div align=left><B>Total</div></B><TD><div align=right>' | egrep -o [0-9]+ | sed -n '10 p')
    echo "$i $slo" >> /home/centos/resource_model/res_data
    if [ "$slo" -lt 50 ]
      then
        break
      fi
    done

# build resource model
cd /home/centos/resource_model
python resource_model.py