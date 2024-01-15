#!/bin/sh

echo "--------------------"
pwd
region=$(yq eval '.settings.region' config.yml)
yaml=".$region.DEM"
pattern=$(yq eval $yaml config.yml)
find . -name "$pattern" > "${region}_files.txt"
echo Process DEM files - "$region"_DEM.tif is output filename.  "$pattern" is filename pattern
echo Files:
cat "$region"_files.txt
echo Build VRT
gdalbuildvrt -input_file_list "$region"_files.txt "$region".vrt
echo Convert VRT to "$region"_tmp.tif
gdal_translate "$region".vrt "$region"_tmp.tif
#echo Scale data to "$1"_2_tmp.tif
#gdal_translate -scale 0 255 -ot Byte "$1"_tmp.tif "$1"_2_tmp.tif -co COMPRESS=LZW
echo Set CRS to "$region"_DEM.tif
# gdalwarp -t_srs epsg:3857 -overwrite -r lanczos -co "COMPRESS=LZW"  "$region"_tmp.tif "$region"_DEM.tif
echo rm "$region"_tmp.tif

