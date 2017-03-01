# oRRDwell

oRRDwell is a monitoring tool, written in bash (except for the config files, in yaml) and on the shoulders of the rrdtool.
It aims to be modular and easily customizable by the user.

Also ships with a backend and front end review the data.
The backend is a small php server that returns json responses and a front end can consume.
The frontend is a React.js app that relays on D3.js to display the data.

**This project is under development.**

## Structure

In the modules folder you can find the source of every module. Every module must load it's configuration and implement the init and the update functions. Also they themselves load their configuration (if needed).
The configuration files are to be place in the configs folder.
Then, the modules are enabled adding them to the field `modules` in the main config.

### `df module` example
`configs/df.yaml`
```yaml
## global definitions
probes: "/,/boot,/home"
names: "root,boot,home"
```
`modules/df.yaml`
```bash
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
```

## License

[LICENSE](LICENSE.md)
