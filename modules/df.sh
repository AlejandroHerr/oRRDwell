function read_df {
  local fs='\'$1'$'
  echo $(echo "$df_reading" | grep -E $fs | awk '{ print $5 }' | sed 's/\%//g')
}

function df_update {
  df_reading=$(df)
  for probe in "${!df_probe[@]}"; do
    update_rrd "$db_folder/df_${df_name[probe]}.rrd" $(read_df "${df_probe[probe]}")
  done
}

function df_init {
  for probe in "${!df_probe[@]}"; do
    dsname="${df_name[probe]}"
    filename="$db_folder/df_$dsname.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "$dsname"
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
