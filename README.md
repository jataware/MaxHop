# Locust Model Process

**Overview**: the Jataware locust model predicts the probability of locust presence in Africa using a maximum entropy model over environmental data such as climate and soil texture. 

This model provides a command line interface which allows 
users to manipulate environmental input conditions against a pre-trained model to predict future locust distributions.



# **I. Model Inputs**

The basic inputs to the Jataware locust model are environmental data such as climate and soil data. The model was trained on known locust locations provided by Locust Hub.

Data were downloaded from:

1.  [https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/20f6245e-40bc-4ade-aff3-a87d3e4fcc26](https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/20f6245e-40bc-4ade-aff3-a87d3e4fcc26)
2.  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/7e8f1bf4-57a1-4b9d-98b5-f1bbf13d3726
    
3.  [https://www.worldclim.org/data/worldclim21.html](https://www.worldclim.org/data/worldclim21.html)
    
4.  https://locust-hub-hqfao.hub.arcgis.com/datasets/hoppers-1

5. https://locust-hub-hqfao.hub.arcgis.com/datasets/hqfao::swarms-1/about

The inputs to the model are:


1.  BIO4 = Temperature Seasonality (standard deviation ×100)
    
2.  BIO8 = Mean Temperature of Wettest Quarter
    
3.  BIO10 = Mean Temperature of Warmest Quarter
    
4.  BIO12 = Annual Precipitation
    
5.  Clay = Soil clay content
    
6.  Sand = Soil sand Content
    
7.  Hopper Data = Presence data for locust hoppers.

8.  Swarm Data = Presence data for locust swarms. 



## II. Getting to know the Model

The model uses maximum entropy (maxent), which is commonly used for species distribution modeling. Though there are many options for species distribution modeling, maxent performs better than others when it comes to presence only data: data where only the species presence has been recorded (not its absence). The locust hopper data used to train and test our model is presence only data which is the main reasoning for choosing maxent over other machine learning models. In the context of machine learning, our training data contained only true positive cases, but no true negatives.

More information about maxent can be found here: https://biodiversityinformatics.amnh.org/open_source/maxent/


**How the maxent model works:**

The maxent model uses environmental data along with species presence data to predict a species probability of presence distribution. “From a set of environmental (e.g., climatic) grids and georeferenced occurrence localities, the model expresses a probability distribution where each grid cell has a predicted suitability of conditions for the species. Under particular assumptions about the input data and biological sampling efforts that led to occurrence records, the output can be interpreted as predicted probability of presence (cloglog transform), or as predicted local abundance (raw exponential output).”(https://biodiversityinformatics.amnh.org/open_source/maxent/). In our use case we are most interested in the complementary log log (cloglog) output raster.

If you are interested in a deeper understanding of the maxent model we recommend reading (“https://web.stanford.edu/~hastie/Papers/maxent_explained.pdf”).

Here is a snippet on how maxent calculates the probabilities for each cell:
“MaxEnt first makes an estimate of the ratio f1(z)/f(z), referred to as MaxEnt’s ‘‘raw’’ output. This is the core of the MaxEnt model output, giving insight about what features are important and estimating the relative suitability of one place vs. another. Because the required information on prevalence is not available for calculating conditional probability of occurrence, a workaround has been implemented (termed MaxEnt’s ‘‘logistic’’ output). This treats the log of the output: g(z) = log(f1(z)/f(z)) as a logit score, and calibrates the intercept so that the implied probability of presence at sites with ‘‘typical’’ conditions for the species (i.e., where g(z) = the average value of g(z) under f1) is a parameter s. Knowledge of s would solve the nonidentifiability of prevalence, and in the absence of that knowledge MaxEnt arbitrarily sets s to equal 0.5.”

“Previous papers have described MaxEnt as estimating a distribution across geographic space (Phillips et al., 2006; Phillips & Dudı´k, 2008). Here, we give a different (but equivalent) characterization that focuses on comparing probability densities in covariate space (Fig. 1).”

**![](https://lh6.googleusercontent.com/yuxv9EoLsR-P9GLf4zHzJXmy5QuUNhyfo209Q1lWIgIa1bQdixwFjwFVx4QqNxRlQCwopdfq3saL7sHtel5KO-aoydd8b5xEnRnjGJSWHcNlQDodnA-4RgElsv9e-FEe9QxXWZ2I)**
**(“[https://web.stanford.edu/~hastie/Papers/maxent_explained.pdf](https://web.stanford.edu/~hastie/Papers/maxent_explained.pdf)”)**

**Our Locust Model:**
 This locust model is based on a paper titled, “Prediction of breeding regions for the desert locust Schistocerca gregaria in East Africa”. In it, the authors created a similar model to predict the breeding locations of locust hoppers in Africa. However, neither the model code nor input data are open source. We wanted to create an open source implementation of this model which predicts the location of desert locusts in the wingless nymph stage of their lifecycle, sometimes referred to as “hoppers”, based on environmental conditions. Beyond having an open access version of a locust model for Africa we wanted to create an interface which allows users to manipulate environmental input conditions to predict potential future locust distributions. This takes the form of a command line interface where a user can increase or decrease the precipitation or temperature of the input data and have an informative raster file returned. Further explained in section IV: CLI Tool.

1.The input data is available, but requires pre-processing, which was not made public by the Kimanthi et al

Kimathi, E., Tonnang, H.E.Z., Subramanian, S. et al. Prediction of breeding regions for the desert locust Schistocerca gregaria in East Africa. Sci Rep 10, 11937 (2020). https://doi.org/10.1038/s41598-020-68895-2


## **III. Training the model**

We provide a pre-trained model as part of our Github repository. This section describes how to update or retrain this model by detailing the model training process.

This model was trained using multiple countries in western Africa. Rasters were cropped based on a western Africa border shapefile (map_1). The reasoning behind this was to expose the model to a variety of environmental conditions where locusts were present and absent.


**![](https://lh6.googleusercontent.com/ZhNlK4u-ucXy4jE_0dC5HE9BbStBn2ioh2RsSOmAAMd-z8qngVVjLSxocjT0simc_KAixrlbvwwF9pDbo6w91TRmxlPSuQlgC9RpBNQMIZ7z1TDU17ytng52P3sppz6ONaqZrxhs)**
Map_1: Training data was cropped by this shapefile, so all rasters lined up exactly.
**![](https://lh5.googleusercontent.com/gPtzqZtdtQNTguq6yuQhTtJALGDI4e80eGoO69bH2aLcpfaz5YnbGSpmMONybzbjRI-nUe-nYqvJFmvqpNfmBgg8RPM4rGjowydhdX5Wu_it1zxESTI_lwve1V1gHLPy8ep0h6lC)**
Map_2: Hopper presence points used in training the model plotted on the cropped soil clay raster layer below.

After the six environmental rasters were cropped to the correct size they were combined into a raster stack. This stack was used in the maxent function in R to train the model on the hopper points and the rasterStack.

  

    maxent_model <- maxent(stack, locust_points, args=c('hinge=false', 'threshold=false'))

  

The next step was to project the model onto the west Africian raster stack to see where the model is predicting suitable habitat for hoppers.

  

    prediction <- project(maxent_model, stack)

  
The model outputs three raster files when projected onto a raster stack. These are raw, logistic, and cloglog. The default is the cloglog raster, which predicts the probability of presence (Map_3).

**![](https://lh6.googleusercontent.com/T9UTYK2DaxeXt2asF2upOtDIPYg7rbEyuRSg6lo4c-ySwpbhGwgTLUikWqQ31HQw3qAJtOefKYR8_p2FLaPmk5oAUL24f4h9Fc8bA8j4SInScezy0zBJ1PApyuLDqI61Y4PuDe1a)**
**Map_3: Predicted locust presence model (cloglog) projected on the training raster stack (western Africa) with the training points plotted.**

Next, we run the maxent model again using different arguments to see if we can improve the model.

    maxent_model_2 <- maxent(stack, locust_points, args=c('hinge=false', 'threshold=false', 'betamultiplier=5'))

    prediction_2 <- project(maxent_model_2, stack)

Compare the models:

    ic(stack(prediction$prediction_raw, prediction_2$prediction_raw),locust_points, list(maxent_model, maxent_model_2))

Output:
|  | n |k|ll|AIC|AICc|BIC
|--|--|--|--|--|--|--|
| Layer.1 |6541  |14|-71978.20|143984.5|143984.5|144079.4
|Layer.2|6541|7|-73069.55|146153.1|146153.1|146200.6

The better model is the first one which is maxent_model. So we save this model as an object with:

    saveRDS(maxent_model,"models/maxent_locust_model_WestAfrica10-16-2020")

## III. Testing the Model
This model was tested on countries across the most common areas in the locust range, with a focus on Ethiopia. To test the model the environmental rasters and the hopper records for that area needed to be cropped for the correct testing area. An example of a layer from Ethiopia, clay percentage, is below.

**![](https://lh3.googleusercontent.com/3yO65nbg3KvN8mMFIUHoRgwY5m5sZMkbPwm7LqHXzmbZGzLsTuW3p_XOaz5YrmU_PeYpxh_3Ngy_i8XcxyhRnftyufUZe1uDj6P8jpl06sY9BkUazgccBZP7CYtY7qTaarU9XcKI)**

Map_4: Shows the raster for Soil Clay percentage for Ethiopia. This will be one layer of our raster stack.

To combine all the rasters into a stack you can use the following code. The stack function takes in rasters and combines them into one rasterStack object. They need to be the same projections and extent before this step. The most confusing step is changing the names of the rasters in the stack to match the rasters used in the training of the model. Since we trained the model on west Africa we need to change the new rasters names using the names function.

    Ethiopia_predictors<-stack(bio4_eth, bio8_eth, bio10_eth, bio12_eth, clay_eth, sand_eth)
    crs(Ethiopia_predictors)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    names(Ethiopia_predictors)<-c("WestAfrica_training_bio4", "WestAfrica_training_bio8", "WestAfrica_training_bio10", "WestAfrica_training_bio12", "WestAfrica_CLYPPT_M_sl2_250m_ll" , "WestAfrica_SNDPPT_M_sl2_250m_ll")

Project the model on the new area and plot the clogclog output.

    prediction_eth<-project(maxent_model, Ethiopia_predictors)
    plot(prediction_eth$prediction_cloglog)

**![](https://lh3.googleusercontent.com/FqHU2zkU9bPagRsbiL5GdRPhxcsVqGiQRSW_LrZ_L3GTR1Dz8tiE9ODv231BfLnTeeZDuTEY_WXPyRKBJdVBn_Z--ispY6jpQjuYyEx8grCDbtDGEU1c13gGiTeynQeRL0p1UKi2)**

Map_5: Plot the prediction cloglog raster.

The green areas of the map are where locusts are predicted to have a higher probability of presences. Let’s plot our locust points to see where the points fall and if the model is making sense. Let’s also change the background color to increase contrast.

    levelplot(prediction_eth$prediction_cloglog, margin=FALSE, col.regions=viridis, at=seq(0, 1, len=100)) +
    latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col="red", alpha=.3))

**![](https://lh4.googleusercontent.com/5-e8VT-Sc3B_7nMPDpOJTPOLKeA7P14Q3OoAzZBA2tqn-rpq1zpDvRBZnmjkxq9eKsEzlmleqTwxVYNYV2tfFigZp7_9Kkt2uZRb2nIKYzdiNgDn1sxlAowhGcSDswsuDJTEFwYW)**

Map_6: cloglog prediction with hopper testing points overlaid.

The points are falling near where the model is predicting points to be located so we can now test to see how well the model will evaluate testing hopper data versus background points. We create two versions of background points. One will be a naive method for selecting background points: a random sample across the whole study area (Map_10) and the other will be based on potential bias of data collection (Map_11). First create the density raster to see how dense the testing data is within our site.

    #create a density map so we can sample unbiased locations
    dens <- kde2d(locust_Eth[,1], locust_Eth[,2], n = c(nrow(occur.ras), ncol(occur.ras)), lims = c(extent(Ethiopia_predictors)[1], extent(Ethiopia_predictors)[2], extent(Ethiopia_predictors)[3], extent(Ethiopia_predictors)[4]))
    dens.ras <- raster(dens, Ethiopia_predictors)
    dens.ras2 <- resample(dens.ras, Ethiopia_predictors)

**![](https://lh3.googleusercontent.com/GHP6qxrL_g4ZDoNoOGcp57hr1yC0BlrFeBgDuVFkaPTxyb_WVEFtKc6L09BW6RVOwl5gVPtckJfgPxaU5cwi_QvGn4PtckNwmfIB2hFSaaD5kgxiqGBrTVUwwz9-aDPRwq34UaVU)**

Map_7: This shows hopper detection locations in Ethiopia.
**![](https://lh6.googleusercontent.com/RTbWO3W3WDMp-9vrzj-OnujmEImb9KLpsJ4ThLRF4Djunv8y_akavdtoNflN5EoQt4L67MUg6nXY6O-ouEUMUHuFyaxX_KvUqC9jIURgE_WGxQQmPGc4edNeBxv7IW2M2a-GAS67)**

Map_8: Right- This map shows the density of hopper detections within Ethiopia.

Looking at the density raster there is a high concentration of data collected in the northeastern part of the country, near Mile Serdo Wildlife Reserve. This could be due to more sampling in that area, or because the environmental conditions there are ideal for locust. To account for potential sampling bias in certain areas we will test the model with background points selected using the weight of the density bias found in the collected data.

    #create 10,000 random background points.
    #bg_corrected is using the bais density raster that we created above.
    
    bg_corrected <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(Ethiopia_predictors, 1)))), 10000, prob=values(dens.ras2)[!is.na(values(subset(Ethiopia_predictors, 1)))]))
    
    #this just selects points based on the extent of the dens.ras2 which is the same as the whole area of Ethiopia
    bg_notCorrected <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(Ethiopia_predictors, 1)))), 10000))

**![](https://lh6.googleusercontent.com/ZD1Sb5HqPBGrVjVkxpYH1A9R4uIXnJTcVf8mm-RwjopdMC9-0uKy-qOeqani2ZvuELRSuAI8VtZNymMAUh2negnR-rXGdKMnLUfgUt19cPpa7BXmOA_THKiLngqvSL8_Ghqk36Uz)**

Map_9: bg_notCorrected points. 

**![](https://lh4.googleusercontent.com/8emMsb9b8vIvo7s3Hbp8DHCOG0GHSgNOEFpyDuaek-MqpVJPhmctLlKbG0baNsTC4qCeUg_18XRZsDvXQ_rg271HE7Qd_9KDdUBb5gBjwwNnrVBRTK3UH01to2G3Im_nkuIHahSG)**

Map_10: bg_corrected points.

The background points have been generated. Maxent uses these background points to create baseline values for the environmental conditions of the area. The model creates a density estimate from the locust points and background points in covariate space then divides the density estimate of our locust points by the density estimate of the background points (Fig_1), the output is the raw raster file. To create the cloglog file a complementary log log transform is applied to the raw output.(see https://web.stanford.edu/~hastie/Papers/maxent_explained.pdf for more details). Now evaluate how well the model performs.


    #convert df of our locust data to spatial points.
    
    Locust_Eth_spatial<-SpatialPoints(Locust_Eth)
    
    eval_notCorrected<-dismo::evaluate(p=Locust_Eth_spatial ,a=bg_notCorrected, model=maxent_model, Ethiopia_predictors)
    
    plot(eval_notCorrected,"ROC")


**![](https://lh4.googleusercontent.com/IGdH-sNsiEmqcy_VmowPaim1zoR34N1jNq2QiXA1QCajH5uWw_M2FDEei454gb3yQrWrfjsRs_KLJq_YyC88Lr3PBREIL_HJoIYb4UceM0I0lf92AjocEqV4a_1rLa12ZfY3vehG)**

    eval_corrected<-dismo::evaluate(p=Locust_Eth_spatial,a=bg, model=maxent_model2, Ethiopia_predictors)
    
    plot(eval_corrected,"ROC")


**![](https://lh3.googleusercontent.com/0gyVUZQwsr1Yy8BEpYXx0CfN6XNCB4DhtBrjyK09k4lVoBodwXx1q1om5ThCAIfo2ztGptNE1u_1l1UIBM6ezMgpQjsUmysHFgOxleJq2M60z57iRNqmCOzBI3ZFNbORyQ7ypvLN)**


The model has a better AUC score when we test with the nonCorrected points (Map_10). When tested with the bg_corrected points the model has a lower AUC score. This makes sense because the model didn’t test with background points in areas where locusts were never recorded, which is most likely due to unsuitable environmental conditions or perhaps a lack of enumerators to collect locust data. The model does better than random even taking into account potential bias in data collection.

For additional information on which environmental variable is limiting the locust distribution we can run a function called limiting and plot the output.


    #plot limiting factors
    
    lim <- limiting(Ethiopia_predictors, maxent_model)
    
    levelplot(lim, col.regions=rainbow) +
    
    latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col=1))

**![](https://lh6.googleusercontent.com/7Mc9ReVYKkapNPGAHlNQqns6pTnxYOmHGaQ5gG_DmgWgfZAAyV03Ws3hPl5p4CA3HnEdHp7SSgsDcQfEkJUyYn-pvg6XEV-YBDLLG_C-tz21MvuPZRtUGUJAdqtJYUrM68CIeZtP)**

Map_11: Limiting environmental variables for locust distribution.

This map shows that the limiting environmental variable for locust presence is bio12, or Annual Precipitation. It is interesting to note that the locust detections are falling where these two limiting factors intersect. A hypothesis could be that there is a “sweet spot” in Ethiopia of precipitation and clay percentage that needs to be met for hopper abundance. The next obvious question is: what would the potential distribution of locusts be with higher annual precipitation, as predicted by climate models. This sensitivity analysis can be achieved through the interactive command line interface described in the next section.

## IV. CLI Tool: Exploring future scenarios

Now that we have tested the model and it is performing well, we can interact with it using a Dockerized CLI tool available on Github. Once it is installed and the docker image is built it will be ready to explore how locust distributions could shift with different environmental conditions.


 **Installation:**
First you need to clone the github repo.

    git clone https://github.com/jataware/MaxHop.git

Once the repo is installed on your computer navigate to the project folder and build the docker image. This will take some time since it is installing a lot of R packages.

    docker build -t cl_maxent_locust_docker .

- *Note: don’t forget to add a period on the end of this to let docker know to build the image using this directory.

The project has a script called maxent_cl.R, which is the main script that runs the model. The model is in the model folder, the raster files for each country are in the rasters folder. The hopper data for a few countries are in the hopper_data folder.

 
To run the docker image go into your terminal and navigate to the project directory. Then run it using this format.


    docker run -v ~/cl_maxent_locust/output:/usr/local/src/myscripts/output cl_maxent_locust_docker "--country=Sudan" "--annualPrecipIncrease=.4" "--meanTempIncrease=-.2" "modeltype=hopper" "--format=GTiff"


This runs the docker container with a volume attached locally in the output folder. The output folder is where the output rasters from the model are saved. The cl_maxent_locust_docker is the image to be run. The parameters are in quotes which are parsed by the r code. These determine which country to use, how much to increase or decrease the Annual Precipitation (--annualPrecipIncrease) or Mean Temperature of Warmest Quarter (--meanTempIncrease), and the type of file output ('GTiff' or 'ascii').

If the example provided above we are setting “country” to Sudan, increasing the Annual Precipitation by 40% across every cell, decreasing Mean Temperature of Warmest Quarter by 20 percent across every cell, and asking for the output to be saved as a tif file.

If no parameters are specified the defaults are country=Ethiopia, --annualPrecipIncrease=0, --meanTempIncrease=0, -- format=GTiff.

**Inputs (all are required)**:

-   **--country**: select a country (see table of available countries below).
    
-   **--annualPrecipIncrease**: a percentage perturbation against annual rainfall (up or down) where 0 is baseline (no perturbation)
    
-   **--meanTempIncrease**: a percentage perturbation against annual mean temperature (up or down) of warmest quarter where 0 is baseline (no perturbation)

-   **--modeltype**: select either the pre-trained model for locust hoppers or swarms. 

| Countries Supported |  
|--|
| Algeria |
|Chad|
|Egypt|
|Eritrea|
|Ethiopia|
|Kenya|
|Libya|
|Mali|
|Mauritania|
|Morocco|
|Niger|
|S.Sudan|
|SaudiArabia (don't use spaces)|
|Somalia|
|Sudan|

|Countries Not Supported|  
|--|
| Djibouti (too small of scale) |  

## V. Swarm Prediction

The model was retrained on presence data for locust swarms with the same countries in western Africa used for the hopper data. The Github repository includes both pre-trained models for locust hoppers and swarms. 


### Difference between hoppers and swarms



<img width="843" alt="Screen Shot 2022-08-13 at 2 48 14 AM" src="https://user-images.githubusercontent.com/66642227/184414978-61b825ea-50d4-4b88-8775-722d48a6e006.png">


Locusts undergo 3 main stages of development: egg, hopper, and adult. We decided to expand the model to account for locusts as adult swarms – their most destructive stage of development. After the locust egg hatches, it grows hind legs to jump or hop around on. During this hopper stage, the locust's movement is largely determined by environmental factors. However, when large amounts of rainfall follow a drought, the behavior of a fully mature adult locust completely changes. Locusts crowd onto small areas of vegetation during droughts and begin to breed rapidly once the rainfall ensues. Their solitary lifestyles shift to gregarious ones in which they travel together as swarms. The locust swarms migrate long distances in search of food; thus, their movement is largely determined by factors related to food and wind. Some research even suggests that swarm movement is  driven by both the "need to find nutrients and to stay with the swarm so that individual locus lessen the chance of falling prey to external predators" (Bazazi, S., Buhl, J., Hale, J.J. et al. Collective Motion and Cannibalism in Locust Migratory Bands. Current Biology, 18, 10 (2008). https://doi.org/10.1016/j.cub.2008.04.035).

### Model Performance

As our locust model predicts the probability of locust presence in Africa using a maximum entropy model over environmental data, we expect a degradation in the performance of the model for locust swarms with respect to hoppers. Though environmental factors can help predict areas rich in nutrients, our model fails to produce a reliable prediction by not considering other factors influencing locust swarm movement. 
