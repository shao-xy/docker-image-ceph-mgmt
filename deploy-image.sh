#!/bin/bash

TARGET_IMAGE=adsl/ceph-dev:latest
TARGET_IMAGE_FILE=adsl-ceph-latest.tar

my_hostname=
my_nodeid=-1

function check_hostname()
{
  my_hostname=$(hostname)
  echo "Get my hostname: ${my_hostname}"
  my_nodeid=${my_hostname#skv-node*}
  echo "Get my nodeid: ${my_nodeid}"
}

function load_from_image()
{
  for i in {1..5}; do
	if test $i -eq $my_nodeid; then continue; fi
	sudo docker image save ${TARGET_IMAGE} | ssh skv-node$i sudo docker load &
  done
  wait
}

function load_from_file()
{
  for i in {1..5}; do
	if test $i -eq $my_nodeid; then continue; fi
	ssh skv-node$i sudo docker load < ${TARGET_IMAGE_FILE} &
  done
  wait
}

function update_image()
{
  # Check if target image exists:
  if test $(sudo docker images -q ${TARGET_IMAGE} | wc -l) -gt 0; then
	load_from_image
  # Check if target image file exists
  elif test -f ${TARGET_IMAGE_FILE}; then
	load_from_file
  else
	echo -e "\e[1;35mTarget image not found either in docker images or files. Abort.\e[0m"
	exit 1
  fi
}

function update_executables()
{
  p -t 1-5 "./docker-images/change-image.sh adsl/ceph-dev:latest"
}

check_hostname
update_image
update_executables
