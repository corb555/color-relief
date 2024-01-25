#!/bin/sh
set -e
echo
echo "------- $(basename $0) -------------"
pwd

# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

# Generate input and output file names using the prefix
input_file="$prefix"_DEM.tif
output_file="$prefix"_hillshade.tif

# Print information about the operation
echo "Hillshade $input_file $output_file"

# todo fix this so if statement isnt needed.  this is to handle horizontal vs vertical units in DEM
if [ "$prefix" = "GEYSER" ]; then
      # Run the second gdaldem statement
    gdaldem hillshade -compute_edges -of GTiff -z 5 "$input_file" "$output_file" -igor || exit $?
else
    # Run the first gdaldem statement
    gdaldem hillshade -compute_edges -of GTiff -z 5 -s 111120 "$input_file" "$output_file" -igor || exit $?
fi