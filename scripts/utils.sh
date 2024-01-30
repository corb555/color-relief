#!/bin/sh

init() {
  set -e
  # Assign the text up to the first underscore in $1 to the variable "region"
  region=$(echo $1 | cut -d'_' -f1)
  config="$region"_config.yml
  echo
  echo "------- $(basename $0) Region: $region -------------"
  pwd
  # Check if the yml config file exists
  [ -f "$config" ] || { echo "Error: Configuration file not found $config"; exit 1; }

  cat $config

  # Record the start time
  start_time=$(date +"%s")
}

# Print elapsed time at end of script
elapsed_time() {
    end_time=$(date +"%s")
    elapsed_time=$((end_time - start_time))
    minutes=$((elapsed_time / 60))
    seconds=$((elapsed_time % 60))
    echo "Elapsed $minutes minutes and $seconds s."
}

