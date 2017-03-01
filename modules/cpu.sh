
function read_cpu {
  echo $(echo "$cpu_reading" | sed -n "$1"p)
}
function read_prev_cpu {
  echo $(echo "$prev_cpu_reading" | sed -n "$1"p)
}
function write_cpu {
  echo "$cpu_reading" > cpu.temp
}
function calculate_use {
  read cpu a b c idle rest < <(read_cpu $1)
  total=$((a+b+c+idle))
  read cpu a b c previdle rest < <(read_prev_cpu $1)
  prevtotal=$((a+b+c+previdle))
  echo "$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))"
}

function cpu_update {
  cpu_reading=$(cat /proc/stat | grep cpu)
  prev_cpu_reading=$(cat cpu.temp | grep cpu)

  I=0
  while [ $I -le $cpu_cpus ]; do
    dsname="${cpu_name[I]}"
    filename="$db_folder/cpu_$dsname.rrd"
    let I=I+1
    update_rrd "$filename" $(calculate_use $I)
  done

  write_cpu
}

function cpu_init {
  I=0
  while [ $I -le $cpu_cpus ]; do
    dsname="${cpu_name[I]}"
    filename="$db_folder/cpu_$dsname.rrd"
    if [ ! -f $filename ]; then
      create_rrd "$filename" "$dsname"
    fi
    let I=I+1
  done
  
  #configure this folder in the config
  touch cpu.temp
}

if [ -f "./configs/cpu.yaml" ]; then
  eval $(parse_yaml "./configs/cpu.yaml" "cpu")
fi
if [ "$cpu_names" ]; then
  names=$cpu_names
  IFS=',' read -r -a cpu_name <<< "$names"
fi
