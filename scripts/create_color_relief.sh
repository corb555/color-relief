#!/bin/sh

# Use the directory of the currently executing script for utils.sh
. "$(dirname "$(readlink -f "$0")")/utils.sh"
# Display script info, get $region and config file
init "$@"

# Create color relief for arid and cool color ramps
for style in "arid" "cool"; do
   echo gdaldem "$region"_DEM.tif "$region"_"$style"_color_ramp.txt "$region"_"$style"_color.tif
    # Check if any of the files is missing
    for file in "$region"_DEM.tif "$region"_"$style"_color_ramp.txt; do
        [ -f "$file" ] || { echo "Error: File not found at $file"; exit 1; }
    done
   gdaldem color-relief -compute_edges -of GTiff -z 3.0 -s 2.0 "$region"_DEM.tif "$region"_"$style"_color_ramp.txt "$region"_"$style"_color.tif &
done

wait
echo DONE
