#!/bin/bash

# Function to calculate and print elapsed time
elapsed_time() {
    end_time=$(date +"%s")
    elapsed_time=$((end_time - start_time))
    minutes=$((elapsed_time / 60))
    seconds=$((elapsed_time % 60))
    echo "Elapsed time $minutes minutes and $seconds s."
}

# Function to merge files and clean up
merge_files() {
    local style=$1
    local output_file="$prefix"_"$style"_relief.tif

    local in_file1="$prefix"_"$style"_color.tif
    local in_file2="$prefix"_hillshade.tif

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
    echo "Merging bands"
    gdal_merge.py -separate -o "$output_file" "${temp_files[@]}"

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
        --NoDataValue=0 --co="COMPRESS=DEFLATE" --type=Byte --overwrite
}


echo "--------------------"
pwd
# Read the region prefix from the YAML config file using yq
prefix=$(yq eval '.settings.region' config.yml)

# Record the start time
start_time=$(date +"%s")

# Define the --calc argument
calculation1="(A.astype(float)*B.astype(float))/255.0"

for style in "arid" "cool"; do
    merge_files "$style"
done

elapsed_time

echo "Done"
