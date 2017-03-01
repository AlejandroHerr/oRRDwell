#function is_my_turn {
#  span=$(($1*$period))
#  echo $(($2%$span))
#}

function parse_yaml {
  local prefix
  if [ $2 ]; then
    prefix="$2_"
  fi
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\):|\1|" \
    -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
    -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {
      if (i > indent) {
        delete vname[i]
      }
    }
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}

function create_rrd {
  rrdcreate $1 \
    --start N \
    -s 60 \
    DS:$2:GAUGE:120:0:U \
    RRA:AVERAGE:0.5:1:60 \
    RRA:AVERAGE:0.5:5:288 \
    RRA:AVERAGE:0.5:30:336 \
    RRA:AVERAGE:0.5:60:744
}

function update_rrd {
  rrdtool update $1 N:$2
}