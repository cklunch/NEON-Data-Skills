---
syncID: a2e5db608b764b029d130970d02c0a8c
title: "Vector 05: Crop Raster Data and Extract Summary Pixels Values From Rasters in R"
description: "This tutorial covers how to modify (crop) a raster extent using the extent of a vector shapefile. It also covers extracting pixel values from defined locations stored in a spatial object."
dateCreated:  2015-10-23
authors: Joseph Stachelek, Leah A. Wasser, Megan A. Jones
contributors: Sarah Newman, Maya R. Stahl
estimatedTime: 1 hour
packagesLibraries: rgdal, raster
topics: vector-data, spatial-data-gis
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/05-vector-raster-integration-advanced.R
tutorialSeries: vector-data-series
urlTitle: dc-crop-extract-raster-data-r
---

This tutorial explains how to crop a raster using the extent of a vector
shapefile. We will also cover how to extract values from a raster that occur
within a set of polygons, or in a buffer (surrounding) region around a set of
points.


<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

 * Crop a raster to the extent of a vector layer.
 * Extract values from raster that correspond to a vector file
 overlay.
 
## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded 
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

* <a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data
<h3><a href="https://ndownloader.figshare.com/files/3708751" > NEON Teaching Data Subset: Site Layout Shapefiles</a></h3>

These vector data provide information on the site characterization and 
infrastructure at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank"> Harvard Forest</a> 
field site.
The Harvard Forest shapefiles are from the 
 <a href="http://harvardforest.fas.harvard.edu/gis-maps/" target="_blank">Harvard Forest GIS & Map</a> 
archives. US Country and State Boundary layers are from the 
<a href="https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html" target="_blank">US Census Bureau</a>.

<a href="https://ndownloader.figshare.com/files/3708751" class="link--button link--arrow">
Download Dataset</a>




<h3> <a href="https://ndownloader.figshare.com/files/3701578"> NEON Teaching Data Subset: Airborne Remote Sensing Data </a></h3>

The LiDAR and imagery data used to create this raster teaching data subset 
were collected over the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank" >Harvard Forest</a>
and 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" >San Joaquin Experimental Range</a>
field sites and processed at NEON headquarters. 
The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/3701578" class="link--button link--arrow"> Download Dataset</a>





****

**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


</div>

## Crop a Raster to Vector Extent
We often work with spatial layers that have different spatial extents.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/vector-general/spatial_extent.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/vector-general/spatial_extent.png" alt="The three different vector types represented within a given spatial extent."></a>
    <figcaption>The spatial extent of a shapefile or R spatial object represents
    the geographic "edge" or location that is the furthest north, south east and 
    west. Thus is represents the overall geographic coverage of the spatial 
    object. Image Source: National Ecological Observatory Network (NEON) 
    </figcaption>
</figure>

The graphic below illustrates the extent of several of the spatial layers that 
we have worked with in this vector data tutorial series:

* Area of interest (AOI) -- blue
* Roads and trails -- purple
* Vegetation plot locations -- black

and a raster file, that we will introduce this tutorial: 

* A canopy height model (CHM) in GeoTIFF format -- green

![Comparison of extents of Roads, Plot Locations, Fisher Tower location, and Canopy Height Model at NEON Harvard Forest Field Site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/view-extents-1.png)



Frequent use cases of cropping a raster file include reducing file size and
creating maps.

Sometimes we have a raster file that is much larger than our study area or area
of interest. In this case, it is often most efficient to crop the raster to the extent of our
study area to reduce file sizes as we process our data.

Cropping a raster can also be useful when creating visually appealing maps so that the
raster layer matches the extent of the desired vector layers.

### Import Data
We will begin by importing four vector shapefiles (field site boundary,
roads/trails, tower location, and veg study plot locations) and one raster
GeoTIFF file, a Canopy Height Model for the Harvard Forest, Massachusetts.
These data can be used to create maps that characterize our study location.

If you have completed the Vector 00-04 tutorials in this 
<a href="https://www.neonscience.org/vector-data-series" target="_blank"> *Introduction to Working with Vector Data in R* </a>
series, you can skip this code as you have already created these object.)


    # load necessary packages
    library(rgdal)  # for vector work; sp package should always load with rgdal. 
    library (raster)
    
    # set working directory to data folder
    # setwd("pathToDirHere")
    
    # Imported in Vector 00: Vector Data in R - Open & Plot Data
    # shapefile 
    aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                                "HarClip_UTMZ18")
    # Import a line shapefile
    lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV/",
                           "HARV_roads")
    # Import a point shapefile 
    point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                          "HARVtower_UTM18N")
    
    # Imported in  Vector 02: .csv to Shapefile in R
    # import raster Canopy Height Model (CHM)
    chm_HARV <- 
      raster("NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")

## Crop a Raster Using Vector Extent
We can use the `crop` function to crop a raster to the extent of another spatial 
object. To do this, we need to specify the raster to be cropped and the spatial
object that will be used to crop the raster. R will use the `extent` of the
spatial object as the cropping boundary.


    # plot full CHM
    plot(chm_HARV,
         main="LiDAR CHM - Not Cropped\nNEON Harvard Forest Field Site")

![NEON Harvard Forest Field Site with a Canopy Height Model overlay.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/Crop-by-vector-extent-1.png)

    # crop the chm
    chm_HARV_Crop <- crop(x = chm_HARV, y = aoiBoundary_HARV)
    
    # plot full CHM
    plot(extent(chm_HARV),
         lwd=4,col="springgreen",
         main="LiDAR CHM - Cropped\nNEON Harvard Forest Field Site",
         xlab="easting", ylab="northing")
    
    plot(chm_HARV_Crop,
         add=TRUE)

![Comparison of original Canopy Height Model extent compared to cropped Canopy Height Model extent.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/Crop-by-vector-extent-2.png)

We can see from the plot above that the full CHM extent (plotted in green) is
much larger than the resulting cropped raster. Our new cropped CHM now has the 
same extent as the `aoiBoundary_HARV` object that was used as a crop extent 
(blue boarder below).

![NEON Harvard Forest Field Site with a Canopy Height Model overlay cropped to the same extent.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/view-crop-extent-1.png)

We can look at the extent of all the other objects. 


    # lets look at the extent of all of our objects
    extent(chm_HARV)

    ## class      : Extent 
    ## xmin       : 731453 
    ## xmax       : 733150 
    ## ymin       : 4712471 
    ## ymax       : 4713838

    extent(chm_HARV_Crop)

    ## class      : Extent 
    ## xmin       : 732128 
    ## xmax       : 732251 
    ## ymin       : 4713209 
    ## ymax       : 4713359

    extent(aoiBoundary_HARV)

    ## class      : Extent 
    ## xmin       : 732128 
    ## xmax       : 732251.1 
    ## ymin       : 4713209 
    ## ymax       : 4713359

Which object has the largest extent?  Our plot location extent is not the 
largest but it is larger than the AOI Boundary. It would be nice to see our
vegetation plot locations with the Canopy Height Model information.

<div id="ds-challenge" markdown="1">
### Challenge: Crop to Vector Points Extent

1. Crop the Canopy Height Model to the extent of the study plot locations. 
2. Plot the vegetation plot location points on top of the Canopy Height Model. 

If you completed the
<a href="https://www.neonscience.org/dc-csv-to-shapefile-r" target="_blank">*.csv to Shapefile in R* tutorial</a>
you have these plot locations as the spatial R spatial object
`plot.locationsSp_HARV`. Otherwise, import the locations from the
`\HARV\PlotLocations_HARV.shp` shapefile in the downloaded data. 

</div>

![Vegetation plots at NEON Harvard Forest Field Site with a Canopy Height Model overlay; note that one vegetation plot appears outside of the overlay.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/challenge-code-crop-raster-points-1.png)

In the plot above, created in the challenge, all the vegetation plot locations
(blue) appear on the Canopy Height Model raster layer except for one. One is
situated on the white space. Why? 

A modification of the first figure in this tutorial is below, showing the 
relative extents of all the spatial objects. Notice that the extent for our 
vegetation plot layer (black) extends further west than the extent of our CHM 
raster (bright green). The crop function will make a raster extent smaller, it 
will not expand the extent in areas where there are no data. Thus, extent of our
vegetation plot layer will still extend further west than the extent of our 
(cropped) raster data (dark green).

![Comparison of extents of Roads, Plot Locations, and both the full-sized and cropped Canopy Height Models at NEON Harvard Forest Field Site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/raster-extents-cropped-1.png)

## Define an Extent
We can also use an `extent()` method to define an extent to be used as a cropping
boundary. This creates an object of class `extent`.


    # extent format (xmin,xmax,ymin,ymax)
    new.extent <- extent(732161.2, 732238.7, 4713249, 4713333)
    class(new.extent)

    ## [1] "Extent"
    ## attr(,"package")
    ## [1] "raster"

Once we have defined the extent, we can use the `crop` function to crop our
raster. 


    # crop raster
    CHM_HARV_manualCrop <- crop(x = chm_HARV, y = new.extent)
    
    # plot extent boundary and newly cropped raster
    plot(aoiBoundary_HARV, 
         main = "Manually Cropped Raster\n NEON Harvard Forest Field Site")
    plot(new.extent, 
         col="brown", 
         lwd=4,
         add = TRUE)
    plot(CHM_HARV_manualCrop, 
         add = TRUE)

![NEON Harvard Forest Field Site with a manually cropped Canopy Height Model overlay.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/crop-using-drawn-extent-1.png)

Notice that our manually set `new.extent` (in red) is smaller than the
`aoiBoundary_HARV` and that the raster is now the same as the `new.extent`
object.
 
See the documentation for the `extent()` function for more ways
to create an `extent` object using `??raster::extent`


## Extract Raster Pixels Values Using Vector Polygons

Often we want to extract values from a raster layer for particular locations - 
for example, plot locations that we are sampling on the ground. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/geospatial-skills/BufferSquare.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/geospatial-skills/BufferSquare.png" alt="Extraction of raster information using a polygon boundary."></a>
    <figcaption> Extract raster information using a polygon boundary. We can
    extract all pixel values within 20m of our x,y point of interest. These can 
    then be summarized into some value of interest (e.g. mean, maximum, total).
    Source: National Ecological Observatory Network (NEON).
    </figcaption>
</figure>

To do this in R, we use the `extract()` function. The `extract()` function
requires:

* The raster that we wish to extract values from
* The vector layer containing the polygons that we wish to use as a boundary or 
boundaries

NOTE: We can tell it to store the output values in a `data.frame` using
`df=TRUE` (optional, default is to NOT return a `data.frame`) .

We will begin by extracting all canopy height pixel values located within our
`aoiBoundary` polygon which surrounds the tower located at the NEON Harvard
Forest field site. 


    # extract tree height for AOI
    # set df=TRUE to return a data.frame rather than a list of values
    tree_height <- raster::extract(x = chm_HARV, 
                           y = aoiBoundary_HARV, 
                           df = TRUE)
    
    # view the object
    head(tree_height)

    ##   ID HARV_chmCrop
    ## 1  1        21.20
    ## 2  1        23.85
    ## 3  1        23.83
    ## 4  1        22.36
    ## 5  1        23.95
    ## 6  1        23.89

    nrow(tree_height)

    ## [1] 18450

When we use the extract command, R extracts the value for each pixel located 
within the boundary of the polygon being used to perform the extraction, in
this case the `aoiBoundary` object (1 single polygon). Using the `aoiBoundary` as the boundary polygon, the
function extracted values from 18,450 pixels.

The `extract` function returns a `list` of values as default, but you can tell R 
to summarize the data in some way or to return the data as a `data.frame`
(`df=TRUE`).

We can create a histogram of tree height values within the boundary to better
understand the structure or height distribution of trees. We can also use the 
`summary()` function to view descriptive statistics including min, max and mean
height values to help us better understand vegetation at our field
site.


    # view histogram of tree heights in study area
    hist(tree_height$HARV_chmCrop, 
         main="Histogram of CHM Height Values (m) \nNEON Harvard Forest Field Site",
         col="springgreen",
         xlab="Tree Height", ylab="Frequency of Pixels")

![Distribution of Canopy Height Model values at NEON Harvard Forest Field Site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/view-extract-histogram-1.png)

    # view summary of values
    summary(tree_height$HARV_chmCrop)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    2.03   21.36   22.81   22.43   23.97   38.17

* Check out the documentation for the `extract()` function for more details 
(`??raster::extract`).

## Summarize Extracted Raster Values 

We often want to extract summary values from a raster. We can tell R the type
of summary statistic we are interested in using the `fun=` method. Let's extract
a mean height value for our AOI. 


    # extract the average tree height (calculated using the raster pixels)
    # located within the AOI polygon
    av_tree_height_AOI <- raster::extract(x = chm_HARV, 
                                  y = aoiBoundary_HARV,
                                  fun=mean, 
                                  df=TRUE)
    
    # view output
    av_tree_height_AOI

    ##   ID HARV_chmCrop
    ## 1  1     22.43018

It appears that the mean height value, extracted from our LiDAR data derived
canopy height model is 22.43 meters.

## Extract Data using x,y Locations

We can also extract pixel values from a raster by defining a buffer or area 
surrounding individual point locations using the `extract()` function. To do this
we define the summary method (`fun=mean`) and the buffer distance (`buffer=20`)
which represents the radius of a circular region around each point.

The units of the buffer are the same units of the data `CRS`.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/geospatial-skills/BufferCircular.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/geospatial-skills/BufferCircular.png" alt="Extraction of raster information using a buffer region."></a>
     <figcaption> Extract raster information using a buffer region. All pixels
    that are touched by the buffer region are included in the extract. 
    Source: National Ecological Observatory Network (NEON).
    </figcaption>
</figure>

Let's put this into practice by figuring out the average tree height in the 
20m around the tower location. 


    # what are the units of our buffer
    crs(point_HARV)

    ## CRS arguments:
    ##  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs

    # extract the average tree height (height is given by the raster pixel value)
    # at the tower location
    # use a buffer of 20 meters and mean function (fun) 
    av_tree_height_tower <- raster::extract(x = chm_HARV, 
                                    y = point_HARV, 
                                    buffer=20,
                                    fun=mean, 
                                    df=TRUE)
    
    # view data
    head(av_tree_height_tower)

    ##   ID HARV_chmCrop
    ## 1  1     22.38812

    # how many pixels were extracted
    nrow(av_tree_height_tower)

    ## [1] 1

<div id="ds-challenge" markdown="1">
### Challenge: Extract Raster Height Values For Plot Locations

Use the plot location points shapefile `HARV/plot.locations_HARV.shp` or spatial
object `plot.locationsSp_HARV` to extract an average tree height value for the
area within 20m of each vegetation plot location in the study area.

Create a simple plot showing the mean tree height of each plot using the `plot()`
function in base-R.
</div>


![Average tree height value for the area within 20m of each vegetation plot location at the NEON Harvard Forest Field Site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-vector-r/05-vector-raster-integration-advanced/rfigs/challenge-code-extract-plot-tHeight-1.png)
