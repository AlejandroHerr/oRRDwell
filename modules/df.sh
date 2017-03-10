function read_df {
  local fs='\'$1'$'
  echo $(echo "$df_reading" | grep -E $fs | awk '{ print $3" "$4" "$5 }' | sed 's/\%//g')
}

function df_update {
  df_reading=$(df)
  for probe in "${!df_probe[@]}"; do
    read used fre perc < <(read_df "${df_probe[probe]}")
    update_rrd "$db_folder/df_${df_rrd_name[probe]}.rrd" $perc
    update_rrd "$db_folder/df_free_${df_rrd_name[probe]}.rrd" $fre
    update_rrd "$db_folder/df_used_${df_rrd_name[probe]}.rrd" $used
  done
}

function df_init {
  for probe in "${!df_probe[@]}"; do
    dsname="${df_rrd_name[probe]}"
    filename="$db_folder/df_$dsname.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "$dsname"
    fi
    filename="$db_folder/df_used_$dsname.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "used_$dsname"
    fi
    filename="$db_folder/df_free_$dsname.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "free_$dsname"
    fi
  done
}


if [ -f "./configs/df.yaml" ]; then
  eval $(parse_yaml "./configs/df.yaml" "df")
fi

if [ "$df_probes" ]; then
  probes=$df_probes
  IFS=',' read -r -a df_probe <<< "$probes"
fi
if [ "$df_names" ]; then
  names=$df_names
  IFS=',' read -r -a df_name <<< "$names"
fi
if [ "$df_rrd_names" ]; then
  rrd_names=$df_rrd_names
  IFS=',' read -r -a df_rrd_name <<< "$rrd_names"
fi
