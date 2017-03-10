function read_loadavg {
  echo $(cat /proc/loadavg | awk '{ print $1" " $2" "$3}')
}

function loadavg_update {
  read load1 load5 load15 free < <(read_loadavg)
  update_rrd "$db_folder/loadavg_${loadavg_name[0]}.rrd" "$load1"
  update_rrd "$db_folder/loadavg_${loadavg_name[1]}.rrd" "$load5"
  update_rrd "$db_folder/loadavg_${loadavg_name[2]}.rrd" "$load15"
}

function loadavg_init {
  if [ ! -f "$db_folder/loadavg_${loadavg_name[0]}.rrd" ]; then
    create_rrd "$db_folder/loadavg_${loadavg_name[0]}.rrd" ${loadavg_name[0]}
  fi
  if [ ! -f "$db_folder/loadavg_${loadavg_name[1]}.rrd" ]; then
    create_rrd "$db_folder/loadavg_${loadavg_name[1]}.rrd" ${loadavg_name[1]}
  fi
  if [ ! -f "$db_folder/loadavg_${loadavg_name[2]}.rrd" ]; then
    create_rrd "$db_folder/loadavg_${loadavg_name[2]}.rrd" ${loadavg_name[2]}
  fi
}

if [ -f "./configs/loadavg.yaml" ]; then
  eval $(parse_yaml "./configs/loadavg.yaml" "loadavg")
fi
if [ "$loadavg_names" ]; then
  names=$loadavg_names
  IFS=',' read -r -a loadavg_name <<< "$names"
fi
