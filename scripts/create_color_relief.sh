#!/bin/sh

echo "--------------------"
pwd
# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

# Create color relief for arid and cool color ramps
for style in "arid" "cool"; do
   echo gdaldem "$prefix"_DEM.tif "$prefix"_"$style"_color_ramp.txt "$prefix"_"$style"_color.tif
   gdaldem color-relief -alpha -of GTiff -z 3.0 -s 2.0 "$prefix"_DEM.tif "$prefix"_"$style"_color_ramp.txt "$prefix"_"$style"_color.tif &
done

wait
echo DONE

