#!/bin/sh
set -e
echo
echo "------- $(basename $0) -------------"
pwd

# Read the region prefix from the config.yml file using yq
region=$(yq eval '.settings.region' config.yml)
echo gdalwarp Set CRS to 3857.  Use "$region"_arid_relief.tif to create "$region"_relief.crs.tif
gdalwarp   -t_srs epsg:3857 -overwrite -r lanczos -co "COMPRESS=LZW"  "$region"_arid_relief.tif "$region"_relief.crs.tif || exit $?

echo "DONE"
