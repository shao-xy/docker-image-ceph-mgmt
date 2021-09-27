#!/bin/bash
# set -e

hosts=(skv-node1 skv-node2 skv-node3 skv-node4 skv-node5)

for host in ${hosts[@]}; do
    echo -e "Host \e[1;31m${host}:\e[0m"
    ssh ${host} sudo docker container ls
done
