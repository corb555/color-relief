#!/bin/sh
# Use the directory of the currently executing script for utils.sh
. "$(dirname "$(readlink -f "$0")")/utils.sh"
# Display script info, get $region and config file
init "$@"

# Get Extent from x_config.yml
xmin=$(yq eval ".regions.$region.extent.xmin" $config)
ymin=$(yq eval ".regions.$region.extent.ymin" $config)
xmax=$(yq eval ".regions.$region.extent.xmax" $config)
ymax=$(yq eval ".regions.$region.extent.ymax" $config)

# Validate if extents are present
if [ -z "$ymax" ]  || [ "$ymax" = "null" ]; then
    echo "Error: Extent is required in $config"
    echo "Missing regions: $region : extent: xmin, xmax, ymin, ymax"
    exit 1
fi

# Get file pattern for DEM files from x_config.yml
pattern=$(yq eval ".regions.$region.DEM" $config)
# Validate if paths are present
if [ -z "$pattern" ] ; then
    echo "Error: File pattern is required in $config for .regions.$region.DEM"
    exit 1
fi

echo Process DEM files - "$region"_DEM.tif is output filename.  "$pattern" is filename pattern

#echo Build VRT
#echo gdalbuildvrt -input_file_list "$region"_files.txt -te $xmin $ymin $xmax $ymax "$region".vrt
#gdalbuildvrt -input_file_list "$region"_files.txt  "$region".vrt || exit $?
#echo Convert VRT to "$region"_tmp.tif
#gdal_translate "$region".vrt "$region"_DEM.tif || exit $?

#echo Scale data to "$1"_2_tmp.tif
#gdal_translate -scale 0 255 -ot Byte "$1"_tmp.tif "$1"_2_tmp.tif -co COMPRESS=LZW
# echo Set CRS to "$region"_DEM.tif
# gdalwarp -t_srs epsg:3857 -overwrite -r lanczos -co "COMPRESS=LZW"  "$region"_tmp.tif "$region"_DEM.tif
#echo rm "$region"_tmp.tif

# gdal_merge.py -o merged_output.tif -ul_lr -180 90 180 -90 -input_file_list input_files.txt

# Get list of files and merge them into tif
echo gdal_merge.py  -o "$region"_DEM.tif
find . -name "$pattern" -exec gdal_merge.py  -o "$region"_DEM.tif  {} + || exit $?
# find . -name "$pattern" -exec gdal_merge.py  -o "$region"_DEM.tif  {} + || exit $?

echo DONE
echo Copy SAMPLE_arid_color_ramp.txt to "$region"_arid_color_ramp.txt and edit it.
