function read_net {
  echo $(echo "$net_reading" | grep $1 | awk '{ print $2" "$3" "$4" "$10" "$11" "$12 }')
}
function read_prev_net {
  echo $(echo "$prev_net_reading" | grep $1 | awk '{ print $2" "$3" "$4" "$10" "$11" "$12 }')
}
function write_net {
  echo "$net_reading" > net.temp
}

function net_update {
  net_reading=$(cat /proc/net/dev)
  prev_net_reading=$(cat net.temp)

  for probe in "${!net_probe[@]}"; do
    read inn inp ine outn outp oute < <(read_net "${net_probe[probe]}")
    read pinn pinp pine poutn poutp poute < <(read_prev_net "${net_probe[probe]}")
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_in.rrd" $(((inn-pinn)/period))
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_in_packets.rrd" $((inp-pinp))
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_in_errors.rrd" $((ine-pine))
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_out.rrd" $((outn-poutn))
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_out_packets.rrd" $((outp-putp))
    update_rrd "$db_folder/net_${net_rrd_name[probe]}_out_errors.rrd" $((oute-pute))
  done

  write_net
}

function net_init {
  for probe in "${!net_probe[@]}"; do
    dsname="${net_rrd_name[probe]}"
    filename="$db_folder/net_${dsname}_in.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_in"
    fi
    filename="$db_folder/net_${dsname}_in_packets.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_in_packets"
    fi
    filename="$db_folder/net_${dsname}_in_errors.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_in_errors"
    fi
    filename="$db_folder/net_${dsname}_out.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_out"
    fi
    filename="$db_folder/net_${dsname}_out_packets.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_out_packets"
    fi
    filename="$db_folder/net_${dsname}_out_errors.rrd"
    if [ ! -f "$filename" ]; then
      create_rrd "$filename" "${dsname}_out_errors"
    fi
  done
}


if [ -f "./configs/net.yaml" ]; then
  eval $(parse_yaml "./configs/net.yaml" "net")
fi

if [ "$net_probes" ]; then
  probes=$net_probes
  IFS=',' read -r -a net_probe <<< "$probes"
fi
if [ "$net_names" ]; then
  names=$net_names
  IFS=',' read -r -a net_name <<< "$names"
fi
if [ "$net_rrd_names" ]; then
  rrd_names=$net_rrd_names
  IFS=',' read -r -a net_rrd_name <<< "$rrd_names"
fi
