**Utilities for creating color relief images using GDAL**

### Overview

### Instructions

create config.yml  -  xmin ymin must be origin  
copy SAMPLE_arid_color_ramp.txt to **region**_arid_color_ramp.txt and same for cool  
run colorReliefEditor and adjust color by elevation  

make  **region**_relief.crs.tif  
copy **region**_relief.crs.tif  to your img folder

### Openstreetmap
Add as a layer in project.mml:  
`  - id: hillshade2  
    Datasource:  
      type: raster  
      file: "img/TETON_relief.crs.tif"`

