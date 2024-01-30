#!/bin/sh
# Use the directory of the currently executing script for utils.sh
. "$(dirname "$(readlink -f "$0")")/utils.sh"
init "$@"

# Read the region prefix from the config.yml file using yq
echo gdalwarp Set CRS to 3857.  Use "$region"_arid_relief.tif to create "$region"_relief.crs.tif
gdalwarp   -t_srs epsg:3857 -overwrite -r lanczos -co "COMPRESS=LZW"  "$region"_arid_relief.tif "$region"_relief.crs.tif || exit $?

echo "DONE"
