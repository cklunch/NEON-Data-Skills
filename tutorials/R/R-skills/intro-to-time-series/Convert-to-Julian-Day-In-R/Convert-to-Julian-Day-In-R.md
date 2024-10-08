---
syncID: 344014eb3c9542f9b491e7955288f8c4
title: "Convert to Julian Day"
description: "This tutorial explains why Julian days are useful and teaches how to create a Julian day variable from a Date or Data/Time class variable."
dateCreated: 2015-10-18
authors: Megan A. Jones, Marisa Guarinello, Courtney Soderberg, Leah A. Wasser
contributors: Collin J. Storlie
estimatedTime: 20 minutes
packagesLibraries: lubridate
topics: time-series
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/intro-to-time-series/Convert-to-Julian-Day-In-R/Convert-to-Julian-Day-In-R.R
tutorialSeries: tabular-time-series
urlTitle: julian-day-conversion-r
---

This tutorial defines Julian (year) day as most often used in an ecological 
context, explains why Julian days are useful for analysis and plotting, and 
teaches how to create a Julian day variable from a Date or Data/Time class 
variable.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

 * Define a Julian day (year day) as used in most ecological 
 contexts.
 * Convert a Date or Date/Time class variable to a Julian day
 variable.

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, RStudio loaded on your computer to complete this tutorial.

### Install R Packages

* **lubridate:** `install.packages("lubridate")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 
<h3> <a href="https://ndownloader.figshare.com/files/3701572" > NEON Teaching Data Subset: Meteorological Data for Harvard Forest</a></h3>

The data used in this lesson were collected at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank"> Harvard Forest field site</a>. 
These data are proxy data for what will be available for 30 years on the
 <a href="http://data.neonscience.org/" target="_blank">NEON data portal</a>
for the Harvard Forest and other field sites located across the United States.

<a href="https://ndownloader.figshare.com/files/3701572" class="link--button link--arrow"> Download Dataset</a>





****
**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


</div>

## Convert Between Time Formats - Julian Days
Julian days, as most often used in an ecological context, is a continuous count 
of the number of days beginning at Jan 1 each year. Thus each year will have up 
to 365 (non-leap year) or 366 (leap year) days. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Note:** This format can also be called ordinal
day or year day. In some contexts, Julian day can refer specifically to a 
numeric day count since 1 January 4713 BCE or as a count from some other origin 
day, instead of an annual count of 365 or 366 days.
</div>

Including a Julian day variable in your dataset can be very useful when
comparing data across years, when plotting data, and when matching your data
with other types of data that include Julian day. 

## Load the Data
Load this dataset that we will use to convert a date into a year day or Julian 
day. 

Notice the date is read in as a character and must first be converted to a Date
class.


    # Load packages required for entire script
    library(lubridate)  #work with dates
    
    # set working directory to ensure R can find the file we wish to import
    wd <- "~/Git/data/"
    
    # Load csv file of daily meteorological data from Harvard Forest
    # Factors=FALSE so strings, series of letters/ words/ numerals, remain characters
    harMet_DailyNoJD <- read.csv(
      file=paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m-NoJD.csv"),
      stringsAsFactors = FALSE
      )
    
    # what data class is the date column? 
    str(harMet_DailyNoJD$date)

    ##  chr [1:5345] "2/11/01" "2/12/01" "2/13/01" "2/14/01" "2/15/01" ...

    # convert "date" from chr to a Date class and specify current date format
    harMet_DailyNoJD$date<- as.Date(harMet_DailyNoJD$date, "%m/%d/%y")

## Convert with yday()
To quickly convert from from Date to Julian days, can we use `yday()`, a 
function from the `lubridate` package. 


    # to learn more about it type
    ?yday

We want to create a new column in the existing data frame, titled `julian`, that
contains the Julian day data.  


    # convert with yday into a new column "julian"
    harMet_DailyNoJD$julian <- yday(harMet_DailyNoJD$date)  
    
    # make sure it worked all the way through. 
    head(harMet_DailyNoJD$julian) 

    ## [1] 42 43 44 45 46 47

    tail(harMet_DailyNoJD$julian)

    ## [1] 268 269 270 271 272 273

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**  In this tutorial we converted from
`Date` class to a Julian day, however, you can convert between any recognized
date/time class (POSIXct, POSIXlt, etc) and Julian day using `yday`.  
</div>
