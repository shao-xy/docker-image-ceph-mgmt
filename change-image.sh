#!/bin/bash -e

fsid=3ce79e60-0d82-11ec-89f4-fff890a7324d
#new_image="adsl/ceph-dev:v1.0"
new_image="adsl/ceph-dev:latest"

if test $(id -u) -ne 0; then
  sudo su -s "$0" $@
  exit
fi

if test ! -z "$1"; then
	new_image="$1"
fi

while read service; do
	cd /var/lib/ceph/${fsid}/${service}
	if [ -f unit.run ]; then
		if [ ! -f unit.run.bak ]; then
			echo -e "Backup \e[1;31m${service}\e[0m."
			cp unit.run unit.run.bak
		fi

		cp unit.run.bak unit.run
		sed -i "s|docker.io/ceph/ceph:v15|${new_image}|g" unit.run

		echo -e "Restart \e[1;31mceph-${fsid}@${service}.service\e[0m now."
		systemctl restart ceph-${fsid}@${service}.service
	else
		continue
	fi
done <<< $(ls /var/lib/ceph/${fsid})
