#!/bin/sh
# Use the directory of the currently executing script for utils.sh
. "$(dirname "$(readlink -f "$0")")/utils.sh"
# Display script info, get $region and config file
init "$@"

# Get flags for hillshade from YML file
flags=$(yq eval ".regions.$region.HILLSHADE" $config)
# Check if the hillshade flags are missing or empty
if [ -z "$flags" ] || [ "$flags" = "null" ]; then
    echo "Error: HILLSHADE flags not found for region '$region' in the configuration."
    exit 1
fi

# Create input and output file names using the region
input_file="$region"_DEM.tif
output_file="$region"_hillshade.tif
# Check if the  file exists
[ -f "$input_file" ] || { echo "Error: Configuration file not found $input_file"; exit 1; }

#   -z 5 -s 111120 -igor
echo gdaldem hillshade -compute_edges -of GTiff $flags "$input_file" "$output_file"  || exit $?

# Run  gdaldem hillshade
gdaldem hillshade -compute_edges -of GTiff $flags "$input_file" "$output_file"  || exit $?
