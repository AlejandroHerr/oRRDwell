function sensor_read {
  echo $(echo "$sensors_reading" | grep "$1" | grep -o '+[0-9]\+' | sed '1~2!d; s/+//' | head -1)
}

function sensors_update {
  sensors_reading=$(sensors)
  for probe in "${!sensors_probe[@]}"; do
    update_rrd "$db_folder/sensors_${sensors_name[probe]}.rrd" $(sensor_read "${sensors_probe[probe]}")
  done
}

function sensors_init {
  for probe in "${!sensors_probe[@]}"; do
    dsname="${sensors_name[probe]}"
    filename="$db_folder/sensors_$dsname.rrd"
    if [ ! -f "$db_folder/sensors_$dsname.rrd" ]; then
      create_rrd "$filename" "$dsname"
    fi
  done
}

if [ -f "./configs/sensors.yaml" ]; then
  eval $(parse_yaml "./configs/sensors.yaml" "sensors")
fi

if [ "$sensors_probes" ]; then
  probes=$sensors_probes
  IFS=',' read -r -a sensors_probe <<< "$probes"
fi

if [ "$sensors_names" ]; then
  names=$sensors_names
  IFS=',' read -r -a sensors_name <<< "$names"
fi
