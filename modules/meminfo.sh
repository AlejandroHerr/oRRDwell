function read_meminfo {
  echo $(echo $(cat /proc/meminfo | head -5| sed 's/[A-Za-z:]*//g') | awk '{ print ($1 - $2 - $4 - $5)" "$4" "$5" "$2}')
}

function meminfo_update {
  read used buffer cached free < <(read_meminfo)
  update_rrd "$db_folder/meminfo_${meminfo_name[0]}.rrd" "$used"
  update_rrd "$db_folder/meminfo_${meminfo_name[1]}.rrd" "$buffer"
  update_rrd "$db_folder/meminfo_${meminfo_name[2]}.rrd" "$cached"
  update_rrd "$db_folder/meminfo_${meminfo_name[3]}.rrd" "$free"
}

function meminfo_init {
  if [ ! -f "$db_folder/meminfo_${meminfo_name[0]}.rrd" ]; then
    create_rrd "$db_folder/meminfo_${meminfo_name[0]}.rrd" ${meminfo_name[0]}
  fi
  if [ ! -f "$db_folder/meminfo_${meminfo_name[1]}.rrd" ]; then
    create_rrd "$db_folder/meminfo_${meminfo_name[1]}.rrd" ${meminfo_name[1]}
  fi
  if [ ! -f "$db_folder/meminfo_${meminfo_name[2]}.rrd" ]; then
    create_rrd "$db_folder/meminfo_${meminfo_name[2]}.rrd" ${meminfo_name[2]}
  fi
  if [ ! -f "$db_folder/meminfo_${meminfo_name[3]}.rrd" ]; then
    create_rrd "$db_folder/meminfo_${meminfo_name[3]}.rrd" ${meminfo_name[3]}
  fi
}

if [ -f "./configs/meminfo.yaml" ]; then
  eval $(parse_yaml "./configs/meminfo.yaml" "meminfo")
fi
if [ "$meminfo_names" ]; then
  names=$meminfo_names
  IFS=',' read -r -a meminfo_name <<< "$names"
fi
