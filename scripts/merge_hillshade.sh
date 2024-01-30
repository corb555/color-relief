#!/bin/bash

# Function to merge files and clean up
merge_files() {
    local style=$1
    local output_file="$region"_"$style"_relief.tif
    local in_file1="$region"_"$style"_color.tif
    local in_file2="$region"_hillshade.tif

    # Check if the  file exists
    for file in "$in_file1" "$in_file2"; do
        [ -f "$file" ] || { echo "Error: File not found at $file"; exit 1; }
    done

    echo "Merge $in_file1 $in_file2 into $output_file"

    # Run gdal_calc.py for each band in parallel
    local temp_files=()

    for ((band = 1; band < 4; band++)); do
        run_gdal_calc "$band" "temp_$band.tif" &
        temp_files+=("temp_$band.tif")
    done

    # Wait for all background processes to finish
    wait

    # Merge the separate bands back into a single RGB file
    echo "Merging bands into $output_file"
    echo input: "${temp_files[@]}"
    gdal_merge.py -v -separate -o "$output_file" "${temp_files[@]}" || exit $?

    # Clean up temporary files
    rm -f "${temp_files[@]}"
}

# Function to run gdal_calc.py with status update for specified band
run_gdal_calc() {
    local band="$1"
    local output_file=$2
    gdal_calc.py -A "$in_file1" -B "$in_file2" \
        --A_band="$band" --B_band=1  \
        --calc="$calculation1" \
        --outfile="$output_file" --extent=intersect --projectionCheck \
        --NoDataValue=0 --co="COMPRESS=DEFLATE" --type=Byte --overwrite || exit $?
}


# Use the directory of the currently executing script for utils.sh
. "$(dirname "$(readlink -f "$0")")/utils.sh"
init "$@"

# Define the --calc argument
calculation1="(A.astype(float)*B.astype(float))/255.0"

for style in "arid" "cool"; do
    merge_files "$style"
done

elapsed_time
echo "Done"
