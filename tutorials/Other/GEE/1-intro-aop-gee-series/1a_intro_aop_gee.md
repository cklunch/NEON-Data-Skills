---
syncID: cd3f3df4c3684bc29cf6feea5cfebe59
title: "Introduction to AOP Public Datasets in Google Earth Engine (GEE)"
description: "Introductory tutorial on exploring AOP Image Collections in Earth Engine."
dateCreated: 2023-05-24
authors: Bridget Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 20 minutes
packagesLibraries: 
topics: lidar, hyperspectral, camera, remote-sensing
languageTool: GEE, JavaScript
dataProduct: DP3.30006.001, DP3.30010.001, DP3.30015.001 DP3.30024.001
code1: 
tutorialSeries: aop-gee2023
urlTitle: intro-aop-gee-image-collections

---

<div id="ds-introduction" markdown="1">

Google Earth Engine (GEE) is a free and powerful cloud-computing platform for carrying out remote sensing and geospatial data analysis. In this tutorial, we introduce you to the NEON AOP datasets, which as of Summer 2024 are being added to Google Earth Engine as publicly available datasets. NEON is planning to add the full archive of AOP L3 <a href="https://data.neonscience.org/data-products/DP3.30006.002" target="_blank">Surface Bidirectional Reflectance</a>, <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">LiDAR Elevation</a>, <a href="https://data.neonscience.org/data-products/DP3.30015.001" target="_blank">Ecosystem Structure</a>, and <a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">High-resolution orthorectified camera imagery</a>. Since the L3 <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">Surface Directional Reflectance</a> is being replaced by the Bidirectional reflectance as that becomes available, we are only adding this data upon request. Please see the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-brdf-refl-h5-py" target="_blank">Introduction to Bidirectional Hyperspectral Reflectance Data in Python</a> for more information on the differences between the directional and bidirectional reflectance data products.

It will take time for the full archive of AOP data to GEE, but NEON is ramping up data additions in the second half of 2024. This tutorial shows you how to see which data are currently available. If you wish to add certain NEON site(s) and year(s) of data into Google Earth Engine, use the <a href="https://www.neonscience.org/about/contact-us" target="_blank">NEON Contact Us</a> form to request this, and include "Google Earth Engine Remote Sensing Data" in the text. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will become familiar with:
 * The Google Earth Engine (GEE)
 * GEE Image Collections

And you will be able to:
 * Write and run basic JavaScript code in code editor 
 * Discover which NEON AOP datasets are available in GEE
 * Explore the NEON AOP GEE Image Collections

## Requirements
 * A gmail (@gmail.com) account.
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/. Click on "Register a Noncommercial or Commercial Cloud Project", and on the next promp select "Unpaid Usage" and select the Project Type to create a free non-commercial account. For more information, refer to <a href="https://earthengine.google.com/noncommercial/" target="_blank">Noncommercial Earth Engine</a>.
 * A Google Cloud Project. See <a href="https://developers.google.com/earth-engine/cloud/earthengine_cloud_project_setup/" target="_blank"> Set up your Earth Engine enabled Cloud Project</a>.
 * A basic understanding of the GEE Code Editor and the GEE JavaScript API.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank">Get Started with Earth-Engine</a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank">GEE JavaScript Tutorial</a>

</div>

## AOP GEE Data Access

AOP has currently added a subset of AOP Level 3 (tiled) data products at over 10 NEON sites spanning 9 years (as of July 2023) on GEE. This data has been converted to Cloud Optimized GeoTIFF (COG) format. NEON L3 lidar and derived spectral indices are available in geotiff raster format, so are relatively straightforward to add to GEE, however the hyperspectral data is available in hdf5 (hierarchical data) format, and have been converted to the COG format prior to being added to GEE.

The NEON data products that have been made available on GEE can be currently be accessed through the `projects/neon-prod-earthengine` folder with an appended suffix of the Acronym and Revision Number, shown in the table below. For example, the Surface Directional Reflectance can be found under the path `projects/neon-prod-earthengine/assets/HSI_REFL/001`. The table below summarizes the Acronyms and Revisions for each data product, and can be used as a reference for reading in AOP GEE datasets. You will learn how to access and read in these data products in the next part of this lesson. 

| Acronym | Revision | Data Product      | Data Product ID |
|---------|----------|-------------------|-----------------|
| HSI_REFL | 001 | Surface Directional Reflectance | <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">DP3.30006.001</a> |
| HSI_REFL | 002 | Surface Bidirectional Reflectance | <a href="https://data.neonscience.org/data-products/DP3.30006.002" target="_blank">DP3.30006.002</a> |
| RGB | 001 | Red Green Blue (Camera Imagery) | <a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">DP3.30010.001</a> |
| DEM | 001 | Digital Surface and Terrain Models (DSM/DTM) | <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">DP3.30024.001</a> |
| CHM | 001 | Ecosystem Structure (Canopy Height Model; CHM) | <a href="https://data.neonscience.org/data-products/DP3.30015.001" target="_blank">DP3.30015.001</a> |

## Get Started with Google Earth Engine

Once you have set up your Google Earth Engine account you can navigate to the <a href="https://code.earthengine.google.com/" target="_blank">Earth Engine Code Editor</a>. The diagram below, from the <a href="https://developers.google.com/earth-engine/guides/playground" target="_blank">Earth-Engine Playground</a>, shows the main components of the code editor. If you have used other programming languages such as R, Python, or Matlab, this should look fairly similar to other Integrated Development Environments (IDEs) you may have worked with. The main difference is that this has an interactive map at the bottom, similar to Google Maps and Google Earth. We encourage you to play around with the interactive map, or explore the ee documentation, linked above, to gain familiarity with the various features.

<figure>
	<a href="https://developers.google.com/earth-engine/images/Code_editor_diagram.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/code_editor_diagram.png" alt="Earth Engine Code Editor Components."></a>
</figure>

## Read AOP Data Collections into GEE using `ee.ImageCollection`

AOP data can currently be accessed through GEE through the `projects/neon-prod-earthengine/assets/` folder. In the remainder of this lesson, we will look at the four available AOP datasets, or `ImageCollections`.

An <a href="https://developers.google.com/earth-engine/guides/ic_creating" target="_blank">ImageCollection</a> is simply a group of images. To find publicly available datasets (primarily satellite data), you can explore the Earth Engine <a href="https://developers.google.com/earth-engine/datasets" target="_blank">Data Catalog</a>. Currently, NEON AOP data cannot be discovered in the main GEE data catalog (this is coming soon!), so the following steps will walk you through how to find available AOP data.

In your code editor, copy and run the following lines of code to create 3 `ImageCollection` variables containing the Surface Directional Reflectance (SDR), Camera Imagery (RGB) and Digital Surface and Terrain Model (DEM) raster data sets. 

```javascript
//read in the AOP image collections as variables

var refl001 = ee.ImageCollection('projects/neon-prod-earthengine/assets/HSI_REFL/001')

var refl002 = ee.ImageCollection('projects/neon-prod-earthengine/assets/HSI_REFL/002')

var rgb = ee.ImageCollection('projects/neon-prod-earthengine/assets/RGB/001') 

var chm = ee.ImageCollection('projects/neon-prod-earthengine/assets/CHM/001')

var dem = ee.ImageCollection('projects/neon-prod-earthengine/assets/DEM/001')
```

A few tips for the working in the Code Editor: 
- In the left panel of the code editor, there is a **Docs** tab which includes API documentation on built in functions, showing the expected input arguments. We encourage you to refer to this documentation, as well as the <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial</a> to familiarize yourself with GEE and the JavaScript programming language.
- If you have an error in your code, a red error message will show up in the Console (in the right panel), which tells you the line that failed.
- Save your code frequently! If you try to leave your code while it is unsaved, you will be prompted that there are unsaved changes in the editor.

When you Run the code above (by clicking on the **Run** above the code editor), you will notice that the lines of code become underlined in red, the same as you would see for a spelling error in most text editors. If you hover over each of the lines of codes, you will see a message pop up that prompts you to Convert the variable into an import record.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/aop_import_record_popup.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/aop_import_record_popup.png" alt="GEE Import Record Popup."></a>
</figure>

If you click `Convert`, the line of code will disappear and the variable will be imported into your session directly, and will show up at the top of the code editor. Go ahead and convert the variables for all three lines of code, so you should see the following. Tip: if you type `Ctrl-z`, you can re-generate the line of code, and the variable will still show up in the imported variables at the top of the editor. It is recommended to retain the code that reads in each variable, for reproducibility. If you don't do this, and wish to share this code with someone else, or run the code outside of your current code editor, the imported variables will not be saved and any subsequent code referring to this variable will result in an error message.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/variable_imports.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/variable_imports.PNG" alt="Imported AOP Image Collections."></a>
</figure>

Note that each of these imported variables can now be expanded, using the arrow to the left of each. These variables now show associated information including *type*, *id*, and *version*. 

Information about the image collections can also be found in a slightly more user-friendly format if you click on the blue link, eg. `projects/neon-prod-earthengine/CHM/001`. Below we'll show the window that pops-up when you click on the CHM link. We encourage you to explore all of the AOP datasets similarly. **Note:** when the GEE datasets become public, you will be able to search for the NEON AOP image collections through the search bar on the <a href="https://developers.google.com/earth-engine/datasets" target="_blank">Earth Engine Data Catalog</a> webpage.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/neon_chm_asset_details.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/neon_chm_asset_details.png" alt="NEON CHM Asset Description."></a>
</figure>

Note that the end of the description includes a link to the Data Product landing page on the NEON Data Portal, as well as the Quick Start Guide, which includes links to all the documentation pertaining to this NEON data product, including the Algorithm Theoretical Basis Documents (ATBDs). Click on the other tabs to explore more about this data product. These tabs include `DESCRIPTION`, `BANDS`, `IMAGE PROPERTIES`, `TERMS OF USE`, AND `CITATIONS`.   

## AOP GEE Data Availability

Since we are adding AOP data to GEE on a rolling basis, the first thing you may want to do after reading in the image collections is to see what datasets are currently available on GEE. A quick way to do this is shown below:

```javascript
// list all available images in the NEON Surface Directional Reflectance Image Collection:
print('NEON Images in the Directional Reflectance Collection',
      refl001.aggregate_array('system:index'))
      
// list all available images in the NEON Surface Bidirectional Reflectance Image Collection:
print('NEON Images in the Bidirectional Reflectance Collection',
      refl002.aggregate_array('system:index'))

// list all available images in the NEON DEM image collection:
print('NEON Images in the DEM Collection',
      dem.aggregate_array('system:index'))

// list all available images in the NEON CHM image collection:
print('NEON Images in the CHM Collection',
      chm.aggregate_array('system:index'))

// list all available images in the NEON CHM image collection:
print('NEON Images in the RGB Camera Collection',
      rgb.aggregate_array('system:index'))
```

In the **Console** tab to the right of the code, you will see a list of all available images. Expand each List to see the data available for each Image Collection. The names of the all the images follow the format `YEAR_SITE_#`, so you can identify the site and year of data this way. The number at the end is the Visit #; AOP typically visits each site 3 out of every 4-5 years, so the visit number indicates the number of times AOP has visited that site. Occasionally, AOP may re-visit a site twice in the same year.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/available_aop_gee_images.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/available_aop_gee_images.PNG" alt="Available AOP Images"></a>
</figure>

## Filter by Image Properties and Display a True Color Image

Next, we can explore some filtering options to pull out individual images from an Image Collection. In the example shown below, we can filter by the date (`.filterDate`) by providing a date range, and filter by other properties, such as the NEON site code, using `.filterMetadata`.

```javascript
// read in a single reflectance image at the NEON site MCRA in 2021
var refl_MCRA_2021 = refl001
  .filterDate('2021-01-01', '2021-12-31') // filter by date - 2021
  .filterMetadata('NEON_SITE', 'equals', 'MCRA') // filter by site
  .first(); // select the first one to pull out a single image
```

## Explore Image Properties

Next let's take a look at the Image Properties.

```
// look at the image properties
var properties = refl_MCRA_2021.toDictionary()
print('MCRA 2021 Directional Reflectance Properties:', properties)
```

Look in the Console for the properties, you can expand by clicking on the arrow to the left of the `Object (438 properties)`. Here you can see some metadata about this image. Scroll down and you'll get to a number of properties starting with `WL_FWHM_B###`. These are the WaveLength (WL) and Full Width Half Max (FWHM) values, in nanometers, corresponding to each band (Bands 001 - 426). You may wish to refer to this wavelength information to determine which bands you wish to display, eg. if you want to show a false color image instead of a true color (RGB) image.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/image_properties.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/image_properties.PNG" alt="SDR Image Properties."></a>
</figure>

When working with NEON data, whether downloaded from the Data Portal, or on GEE, we always recommend checking whether the data are Provisional or Released, and the release tag of the data. On GEE, this information is included in the image properties `PROVISIONAL_RELEASED` and `RELEASE_YEAR`. If the data is released, the property `RELEASE_YEAR` will display the year of the release. Use the code below to display this information for the MCRA 2021 directional reflectance data. For more information on NEON releases, refer to the <a href="https://www.neonscience.org/data-samples/data-management/data-revisions-releases" target="_blank">NEON Data Product Revisions and Releases</a> page.

```
// determine the release information for this image
// see https://www.neonscience.org/data-samples/data-management/data-revisions-releases
var release_status = properties.select(['PROVISIONAL_RELEASED']);
print('MCRA 2021 Directional Reflectance Release Status:', release_status)
var release_year = properties.select(['RELEASE_YEAR']);
print('MCRA 2021 Directional Reflectance Release Year:', release_year)
```

In this example, the data is part of `RELEASE-2024`.

## Plot a True Color Image

Finally, let's plot a true color image (red-green-blue or RGB composite) of the reflectance data that we've read into the variable `refl_MCRA_2021`. To do this, first we pull out the RGB bands, set visualization parameters, center the map over the site, and then add the map using `Map.addLayer`.

```javascript
// pull out the red, green, and blue bands
var refl001_MCRA_2021_RGB = refl_MCRA_2021.select(['B053', 'B035', 'B019']);

// set visualization parameters
var rgb_vis = {min: 0, max: 1260, gamma: 0.8};

// center the map at the lat / lon of the site, set zoom to 13
Map.setCenter(-122.15, 44.27, 13);

// add this RGB layer to the Map and give it a title
Map.addLayer(refl001_MCRA_2021_RGB, rgb_vis, 'MCRA 2021 RGB Reflectance Imagery');
```

When you run the code you should now see the true color images on the map! You can zoom in and out and explore some of the other interactive options on your own.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/mcra_sdr_rgb.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/mcra_sdr_rgb.png" alt="MCRA Reflectance RGB Image."></a>
</figure>

## A Quick Recap

You did it! You now have a basic understanding of the GEE code editor and it's different components. You have also learned how to read a NEON AOP `ImageCollection` into a variable, import the variable into your code editor session, and navigate through the ImageCollection **Asset details** to display information about the collection. Lastly, you learned to read in an individual reflectance image, explore the image properties, and display a map of a true color image (RGB composite).

It doesn't look like we've done much so far, but this is a already great achievement! With just a few lines of code, you can import an entire AOP hyperspectral dataset, which in most other coding environments, is more involved. One of the major challenges to working with AOP reflectance data is it's large data volume, which typically requires high-performance computing environments to read in the data, visualize, and analyze it. There are also limited open-source tools for working with hyperspectral data; many of the established software suites require proprietary (and often expensive) licenses. In this lesson, with minimal code, we have loaded spectral, lidar, and camera data covering an entire AOP site, and are ready to start exploring and analyzing the data in a free geospatial cloud-computing platform. 

## Get Lesson Code

<a href="https://code.earthengine.google.com/6dac70b411f46e34275f1fbb20eaaa65" target="_blank">Into to AOP GEE Image Collections</a>