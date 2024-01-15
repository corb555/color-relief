#!/bin/sh

echo "-------WARNING verify FILE -------------"
pwd
echo gdalwarp Set CRS to 3857.  Use "$1".tif to create "$1".crs.tif
gdalwarp   -t_srs epsg:3857 -overwrite -r lanczos -co "COMPRESS=LZW"  "$1".tif "$1".crs.tif
echo DONE
