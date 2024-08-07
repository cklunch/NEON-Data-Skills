## ----set-up, message=FALSE-------------------------------------------

install.packages("maptools")

# Load needed packages
library(raster)
library(rgdal)
library(dplyr)

# Method 3:shapefiles
library(maptools)

# plotting
library(ggplot2)

# set working directory to ensure R can find the file we wish to import and where
wd <- "~/Git/data/" #This will depend on your local environment
setwd(wd)


## ----read-veg--------------------------------------------------------

# import the centroid data and the vegetation structure data
# this means all strings of letter coming in will remain character
options(stringsAsFactors=FALSE)

# read in plot centroids
centroids <- read.csv(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/SJERPlotCentroids.csv"))
str(centroids)

# read in vegetation heights
vegStr <- read.csv(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/VegetationData/D17_2013_vegStr.csv"))
str(vegStr)



## ----plot-CHM--------------------------------------------------------

# import the digital terrain model
chm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/CHM_SJER.tif"))

# plot raster
plot(chm, main="Lidar Canopy Height Model \n SJER, California")



## ----plot-veg--------------------------------------------------------

## overlay the centroid points and the stem locations on the CHM plot
# plot the chm
myCol <- terrain.colors(6)
plot(chm,col=myCol, main="Plot & Tree Locations", breaks=c(-2,0,2,10,40))

## plotting details: cex = point size, pch 0 = square
# plot square around the centroid
points(centroids$easting,centroids$northing, pch=0, cex = 2 )
# plot location of each tree measured
points(vegStr$easting,vegStr$northing, pch=19, cex=.5, col = 2)



## ----check-CRS-------------------------------------------------------
# check CHM CRS
chm@crs



## ----createSpatialDf-------------------------------------------------
## create SPDF: SpatialPointsDataFrame()
# specify the easting (column 4) & northing (columns 3) in that order
# specify CRS proj4string: borrow CRS from chm 
# specify raster
centroid_spdf <- SpatialPointsDataFrame(
  centroids[,4:3], proj4string=chm@crs, centroids)

# check centroid CRS
# note SPDFs don't have a crs slot so `object@crs` won't work
centroid_spdf



## ----extract-plot-data-----------------------------------------------

# extract circular, 20m buffer

cent_max <- raster::extract(chm,             # raster layer
	centroid_spdf,   # SPDF with centroids for buffer
	buffer = 20,     # buffer size, units depend on CRS
	fun=max,         # what to value to extract
	df=TRUE)         # return a dataframe? 

# view
cent_max



## ----fix-ID----------------------------------------------------------

# grab the names of the plots from the centroid_spdf
cent_max$plot_id <- centroid_spdf$Plot_ID

#fix the column names
names(cent_max) <- c('ID','chmMaxHeight','plot_id')

# view again - we have plot_ids
cent_max

# merge the chm data into the centroids data.frame
centroids <- merge(centroids, cent_max, by.x = 'Plot_ID', by.y = 'plot_id')

# have a look at the centroids dataFrame
head(centroids)



## ----explore-data-distribution---------------------------------------
# extract all
cent_heightList <- raster::extract(chm,centroid_spdf,buffer = 20)

# create histograms for the first 5 plots of data
# using a for loop

for (i in 1:5) {
  hist(cent_heightList[[i]], main=(paste("plot",i)))
  }



## ----challenge-code-loops, echo=FALSE, eval=FALSE, comment=NA--------
# set parameters for graphics
par(mfrow=c(6,3))

# create histograms using a for loop

for (i in 1:18) {
  hist(cent_heightList[[i]], main=(paste("plot",i)))
  }

# return par to normal 
par(mfrow=c(1,1))



## ----square-plot, eval=FALSE-----------------------------------------
## #Will need to load 'sp' package 'library(sp)'
## square_max <- raster::extract(chm,             # raster layer
## 	polys,   # spatial polygon for extraction
## 	fun=max,         # what to value to extract
## 	df=TRUE)         # return a dataframe?
## 


## ----read-shapefile--------------------------------------------------
# load shapefile data
centShape <- readOGR(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/SJERPlotCentroids_Buffer.shp"))

plot(centShape)



## ----extract-w-shapefile---------------------------------------------
# extract max from chm for shapefile buffers
centroids$chmMaxShape <- raster::extract(chm, centShape, weights=FALSE, fun=max)

# view
head(centroids)



## ----challenge-code-square-shape, include=TRUE, results="hide", echo=FALSE, warning=FALSE, fig.show='hide'----
# load shapefile data
squareShape <- readOGR(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/SJERPlotCentroids_Buff_Square.shp"))

plot(squareShape)

# extract max from chm for shapefile buffers
centroids$chmMaxSquareShape <- raster::extract(chm, squareShape, weights=FALSE, fun=max)

# calculate the difference between the two methods
centroids$diff <- centroids$chmMaxSquareShape-centroids$chmMaxShape

# view
head(centroids)



## ----analyze-base-r--------------------------------------------------
# find max stemheight
maxStemHeight <- aggregate( vegStr$stemheight ~ vegStr$plotid, 
														FUN = max )  

# view
head(maxStemHeight)

#Assign cleaner names to the columns
names(maxStemHeight) <- c('plotid','insituMaxHeight')

# view
head(maxStemHeight)



## ----trees-95--------------------------------------------------------
# add the max and 95th percentile height value for all trees within each plot
insitu <- cbind(maxStemHeight,'quant'=tapply(vegStr$stemheight, 
	vegStr$plotid, quantile, prob = 0.95))

# view
head(insitu)



## ----analyze-plot-dplyr----------------------------------------------

# find the max stem height for each plot
maxStemHeight_d <- vegStr %>% 
  group_by(plotid) %>% 
  summarise(max = max(stemheight))

# view
head(maxStemHeight_d)

# fix names
names(maxStemHeight_d) <- c("plotid","insituMaxHeight")
head(maxStemHeight_d)



## ----bonus-dplyr-----------------------------------------------------

# one line of nested commands, 95% height value
insitu_d <- vegStr %>%
	filter(plotid %in% centroids$Plot_ID) %>% 
	group_by(plotid) %>% 
	summarise(max = max(stemheight), quant = quantile(stemheight,.95))

# view
head(insitu_d)



## ----merge-dataframe-------------------------------------------------

# merge the insitu data into the centroids data.frame
centroids <- merge(centroids, maxStemHeight, by.x = 'Plot_ID', by.y = 'plotid')

# view
head(centroids)



## ----plot-data-------------------------------------------------------

#create basic plot
plot(x = centroids$chmMaxShape, y=centroids$insituMaxHeight)



## ----plot-w-ggplot---------------------------------------------------

# create plot

ggplot(centroids,aes(x=chmMaxShape, y =insituMaxHeight )) + 
  geom_abline(slope=1, intercept = 0, alpha=.5, lty=2)+ # plotting our "1:1" line
  geom_point() + 
  theme_bw() + 
  ylab("Maximum measured height") + 
  xlab("Maximum lidar pixel")



## ----ggplot-data-full------------------------------------------------
# plot with regression

ggplot(centroids, aes(x=chmMaxShape, y=insituMaxHeight)) +
  geom_abline(slope=1, intercept=0, alpha=.5, lty=2) + #plotting our "1:1" line
  geom_point() +
  geom_smooth(method = lm) + # add regression line and confidence interval
  ggtitle("Lidar CHM-derived vs. Measured Tree Height") +
  ylab("Maximum Measured Height") +
  xlab("Maximum Lidar Height") +
  theme(panel.background = element_rect(colour = "grey"),
        plot.title = element_text(family="sans", face="bold", size=20, vjust=1.19),
        axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2),
        axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1))



## ----challenge-code-plot-95, include=TRUE, results="hide", echo=FALSE, fig.show='hide'----
# 1. Add 95 data to centroids df
centroids_c <- merge(centroids, insitu, by.x = 'Plot_ID', by.y = 'plotid')

# 2. Plot 95 data vs insitu data
ggplot(centroids_c,aes(x=quant, y =insituMaxHeight.x )) + 
  geom_abline(slope=1, intercept = 0, alpha=.5, lty=2)+ # plotting our "1:1" line
  geom_point() + 
  ylab("Maximum Measured Height") + 
  xlab("95% quantile lidar Height")+
  geom_smooth(method=lm) 



