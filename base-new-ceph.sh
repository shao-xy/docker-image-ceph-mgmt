#!/bin/bash
set -e

hosts=(skv-node1 skv-node2 skv-node3 skv-node5)

echo -e "Deploy new ceph on \e[1;31m${hosts[*]}\e[0m."
echo -ne "Continue? [y/n] "

read c

if [ $c = "n" ]; then
	exit
fi

if [ -a ./adsl-ceph.tar ]; then
	echo -n "adsl/ceph-dev docker image tar file already exists, do you want to regenerate? [y/n] "
	read c
	if [ $c = "y" ]; then
		sudo docker save adsl/ceph-dev -o adsl-ceph.tar
		echo -e "\e[1;31mFinish generating docker image tar file.\e[0m"
	fi
else
	sudo docker save adsl/ceph-dev -o adsl-ceph.tar
	echo -e "\e[1;31mFinish generating docker image tar file.\e[0m"
fi

sudo chown cephgroup:cephgroup adsl-ceph.tar 

echo -n "Copy image to hosts? [y/n] "

read c
if [ $c = "y" ]; then
	for host in ${hosts[@]}; do
		scp adsl-ceph.tar $host:~/docker-images/adsl-ceph.tar
		ssh $host sudo docker load -i ~/docker-images/adsl-ceph.tar
	done
fi

for host in ${hosts[@]}; do
	echo -e "Restarting service on \e[1;31m${host}\e[0m."
	scp change-image.sh $host:~/docker-images/change-image.sh
	ssh $host chmod 700 ~/docker-images/change-image.sh
	ssh $host sudo ~/docker-images/change-image.sh
done
