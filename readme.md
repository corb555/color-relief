**Utilities for creating color relief images using GDAL**

### Overview

### Instructions

create config.yml  
copy SAMPLE_arid_color_ramp.txt to **region**_arid_color_ramp.txt  
run colorReliefEditor to set color by elevation  

make  **region**_relief.crs.tif  
copy **region**_relief.crs.tif  to your img folder

### Openstreetmap
Add as a layer in project.mml:  
`  - id: hillshade2  
    Datasource:  
      type: raster  
      file: "img/TETON_relief.crs.tif"`


