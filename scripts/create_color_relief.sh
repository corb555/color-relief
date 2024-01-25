#!/bin/sh
set -e
echo
echo "------- $(basename $0) -------------"
pwd

# Read the region prefix from the config.yml file using yq
region=$(yq eval '.settings.region' config.yml)

# Create color relief for arid and cool color ramps
for style in "arid" "cool"; do
   echo gdaldem "$region"_DEM.tif "$region"_"$style"_color_ramp.txt "$region"_"$style"_color.tif
   gdaldem color-relief -compute_edges -alpha -of GTiff -z 3.0 -s 2.0 "$region"_DEM.tif "$region"_"$style"_color_ramp.txt "$region"_"$style"_color.tif &
done

wait
exit_statuses=($?)

# Check for any errors and exit with the first non-zero exit status
for status in "${exit_statuses[@]}"; do
    if [ "$status" -ne 0 ]; then
        echo "Error: gdaldem failed with exit status $status"
        exit $status
    fi
done

echo DONE

