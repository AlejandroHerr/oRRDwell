#!/bin/bash
source ./common.sh

declare -a MODULES

if [ -f "./config.yaml" ]; then
  eval $(parse_yaml "./config.yaml")
fi

if [ ! -d $db_folder ]; then
  mkdir $db_folder
fi


IFS=',' read -r -a modules <<< "$modules"
for module in "${!modules[@]}"; do
  filename="./modules/${modules[module]}.sh"
  if [ -f $filename ]; then
    source "$filename";
    ${modules[module]}_init
  fi
done

sleep $((60-($(date +%s)%60)))
while [ 1 ]; do
  TIME=$(date +%s)
  for module in "${!modules[@]}"; do
    ${modules[module]}_update
  done
  sleep $(($period-($(date +%s)%$period)))
done
