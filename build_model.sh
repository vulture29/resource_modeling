#!/bin/bash

# check and delete old file
if [ -f "/home/centoslive/resource_model/res_data" ]; then
  rm /home/centoslive/resource_model/res_data
fi

cd /home/centoslive/RUBiS
kvm_host_ip="13.82.55.56"
kvm_host_user="zhikangzhang"
vm_pid="4136 4141"

echo "Start building resource model..."

# control cpu cgroup in the server
for i in {20..100..1}
  do
    echo "Test for performance under cgroup $i..."
    user_command="
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
                    cpu.cfs_quota_us = ${i}000;
                    cpu.cfs_period_us = 100000;
            }
    }' > ~/cgconfig.conf
    sudo cp ~/cgconfig.conf /etc/cgconfig.conf
    sudo service cgconfig restart
    sudo cgclassify -g cpu:limitcpu $vm_pid
    nohup /home/$kvm_host_user/resource_model/monitor_pressure.sh $i > /dev/null 2>&1 &
    "
    ssh "$kvm_host_user@$kvm_host_ip" "$user_command"

    perf_path=$(make emulator | awk 'NR==4{ print $4 ; exit }')
    slo=$(cat /home/centoslive/RUBiS/${perf_path}perf.html | grep '<TR><TD><div align=left><B>Total</div></B><TD><div align=right>' | egrep -o [0-9]+ | sed -n '10 p')
    ssh "$kvm_host_user@$kvm_host_ip" "sudo kill -9 \$(ps aux | grep monitor_pressure.sh | awk '{ print \$2 }')"
    scp $kvm_host_user@$kvm_host_ip:/home/$kvm_host_user/resource_model/pressure_data /home/centoslive/resource_model/pressure_data
    pressure=$(python /home/centoslive/resource_model/calculate_pressure.py)
    echo "$pressure $slo" >> /home/centoslive/resource_model/res_data
    if [ "$slo" -lt 200 ]
      then
        echo "No SLO violation!"
        break
      fi
  done

# build resource model
cd /home/centoslive/resource_model
# python resource_model.py