# Makefile

# Define the list of layers
LAYERS := layer1 layer2 layer3

# Default target to build all layers
all: $(addsuffix _layer.tif,$(LAYERS))

# Rule to create DEM VRT
%-DEM.vrt:
	create_vrt.sh $*

# Rule to create DEM.tif from DEM VRT
%-DEM.tif: %-DEM.vrt
	gdal_translate $< $@

# Rule to create precip_tmp.tif
%-precip_tmp.tif:
	create_precip.sh $*

# Rule to create layer.tif from DEM.tif and precip_tmp.tif
%-layer.tif: %-DEM.tif %-precip_tmp.tif
	merge_arid.sh $*

# Clean rule to remove intermediate files
clean:
	rm -f *-DEM.vrt *-DEM.tif *-precip_tmp.tif

# Clean all rule to remove all generated files
clean-all: clean
	rm -f *-layer.tif

.PHONY: all clean clean-all
