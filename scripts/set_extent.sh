#!/bin/bash

# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

source_geotiff="$prefix"_arid_relief.tif
target_geotiff="$prefix"_precip.tif
output_geotiff="$prefix"_precip_ext.tif

pwd
echo Set the extent and dimensions of $target_geotiff to match $source_geotiff and output as $output_geotiff

# Get gdalinfo in JSON format from the source GeoTIFF
gdalinfo_result=$(gdalinfo -json "$source_geotiff")

# Extract coordinates from gdalinfo JSON output using jq
xmin=$(jq -r '.cornerCoordinates.upperLeft[0]' <<< "$gdalinfo_result")
ymax=$(jq -r '.cornerCoordinates.upperLeft[1]' <<< "$gdalinfo_result")

xmax=$(jq -r '.cornerCoordinates.lowerRight[0]' <<< "$gdalinfo_result")
ymin=$(jq -r '.cornerCoordinates.lowerRight[1]' <<< "$gdalinfo_result")

# Extract dimensions from the gdalinfo JSON output using jq
width=$(jq -r '.size[0]' <<< "$gdalinfo_result")
height=$(jq -r '.size[1]' <<< "$gdalinfo_result")

echo Coordinates "$xmin" , "$ymin" , "$xmax" , "$ymax"

# Use gdalwarp to apply settings to the target file
echo gdalwarp -overwrite  -r lanczos -te "$xmin" "$ymin" "$xmax" "$ymax"  -ts $width $height -of GTiff  "$target_geotiff"  "$output_geotiff"
gdalwarp -overwrite  -r lanczos -te "$xmin" "$ymin" "$xmax" "$ymax"  -ts $width $height -of GTiff  "$target_geotiff"  "$output_geotiff"
echo DONE
