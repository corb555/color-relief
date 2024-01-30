# Specify the directory where scripts are located
SCRIPTS_DIR := color-relief/scripts

# Define common dependencies
# All files start with <region>_
COMMON_DEPS := %_config.yml %_DEM.tif %_arid_color_ramp.txt

# Create DEM file from config.yml definition
%_DEM.tif: %_config.yml
	$(SCRIPTS_DIR)/init_DEM.sh $@

# Create hillshade file from DEM
%_hillshade.tif: %_config.yml %_DEM.tif
	$(SCRIPTS_DIR)/create_hillshade.sh $@

# Create color relief file from DEM and color ramp
%_arid_color.tif: $(COMMON_DEPS)
	$(SCRIPTS_DIR)/create_color_relief.sh $@

# Merge color relief and hillshade
%_arid_relief.tif: $(COMMON_DEPS) %_hillshade.tif  %_arid_color.tif
	$(SCRIPTS_DIR)/merge_hillshade.sh $@

# Set CRS for color relief file
%_relief.crs.tif: $(COMMON_DEPS) %_hillshade.tif  %_arid_color.tif %_arid_relief.tif
	$(SCRIPTS_DIR)/set_crs.sh $@

.PRECIOUS: %_DEM.tif  %_arid_color.tif %_hillshade.tif

# Target to run all steps
all: %_relief.crs.tif

