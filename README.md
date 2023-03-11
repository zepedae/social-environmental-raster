# Create a Raster with Social and Environmental Characteristic Layers

## Social Characteristics Using US Census Data
The social raster contains data on the socioeconomic and demographic characteristics
of people living in the Chicago Metropolitan Area. Using the R package, tidycensus 
(Walker and Herman 2023).

The data was extracted at the Census block group level and then rasterized to a 
resolution of 30 m^2 using the raster packaage in R (Hijmans 2022).

## Environmental Characteristics Using CMAP Data



@Manual{,
  title = {tidycensus: Load US Census Boundary and Attribute Data as 'tidyverse' and 'sf'-Ready Data Frames},
  author = {Kyle Walker and Matt Herman},
  year = {2023},
  note = {R package version 1.3.2},
  url = {https://walker-data.com/tidycensus/},
}

@Manual{,
    title = {raster: Geographic Data Analysis and Modeling},
    author = {Robert J. Hijmans},
    year = {2022},
    note = {R package version 3.5-29},
    url = {https://CRAN.R-project.org/package=raster},
  }