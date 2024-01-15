#!/bin/sh

echo "--------------------"
pwd

# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

# Generate input and output file names using the prefix
input_file="$prefix"_DEM.tif
output_file="$prefix"_hillshade.tif

# Print information about the operation
echo "Hillshade $input_file $output_file"
gdaldem hillshade  -compute_edges -of GTiff -z 5 -s 111120 $input_file $output_file  -igor
