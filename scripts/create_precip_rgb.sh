#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Error - Usage: create_precip_out_file.sh <min value> <max value>"
    exit 1
fi

echo
pwd
# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

precip_file="$prefix"_precip_ext.tif
precip_out_file="$prefix"_precip_rgb.tif

# temp files
precip_byte_file=precip_tmpb.tif
precip_vrt_file=precip_tmpv.vrt

echo Convert grayscale precip file $precip_file to RGB and scale $1 $2 to 0 255
echo Output "$precip_out_file"

# Convert the precipitation file to Byte data type and rescale it
echo gdal_translate -scale $1 $2 0 255 -ot Byte "$precip_file" "$precip_byte_file"
gdal_translate -scale $1 $2 0 255 -ot Byte "$precip_file" "$precip_byte_file"

# Create a virtual raster with three identical bands from precip grayscale file
gdalbuildvrt -separate "$precip_vrt_file" "$precip_byte_file" "$precip_byte_file" "$precip_byte_file"

# Convert the virtual raster to a real RGB file
gdal_translate -ot Byte -of GTiff -co PHOTOMETRIC=RGB "$precip_vrt_file" "$precip_out_file"
rm "$precip_vrt_file"
rm "$precip_byte_file"
