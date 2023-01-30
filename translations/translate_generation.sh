#!/bin/bash
# this file is used to auto-generate .qm file from .ts file.

cd $(dirname $0)

ts_list=$(ls ./*.ts)

for ts in "${ts_list[@]}"
do
#    printf "\nprocess ${ts}\n"
    lrelease "${ts}"
done
