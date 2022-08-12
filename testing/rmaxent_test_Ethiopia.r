#test model on Countries
#bring in ethiopia rasters
library(devtools)
install_github('johnbaums/rmaxent')
library(rmaxent)
require(magrittr)
require(dismo)
require(raster)
require(rasterVis)
require(viridis)
require(sp)
require(ggplot2)
require(MASS)
require(rgdal)

maxent_model2<-readRDS("model/maxent_locustswarm_model_WestAfrica7-26-2022")

bio4_eth <- raster("rasters/Ethiopia_bio4.asc")
bio8_eth <- raster("rasters/Ethiopia_bio8.asc")
bio10_eth <- raster("rasters/Ethiopia_bio10.asc")
bio12_eth <- raster("rasters/Ethiopia_bio12.asc")
clay_eth <- raster("rasters/Ethiopia_CLYPPT_M_sl2_250m_ll.asc")
snd_eth <- raster("rasters/Ethiopia_SNDPPT_M_sl2_250m_ll.asc")
maxent_model2
clay_eth
plot(clay_eth)
bio12_eth
plot(bio12_eth)

Ethiopia_predictors<-stack(clay_eth, bio10_eth, bio12_eth, bio4_eth, bio8_eth,clay_eth)
crs(Ethiopia_predictors)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
names(Ethiopia_predictors)<-c("westAfrica_CLYPPT", "westAfrica_bio10", "westAfrica_bio12", "westAfrica_bio4", "westAfrica_bio8", "westAfrica_SNDPPT" )
Ethiopia_predictors

#Prediction on Ethiopia based on new model

prediction_eth<-rmaxent::project(maxent_model2, Ethiopia_predictors)
prediction_eth
plot(prediction_eth$prediction_raw)

#Bring in Locust hopper points to plot on top of prediction raster.

locust_Eth <- read.csv('swarmdata/swarms_ethiopia.csv',header=TRUE, sep=',')
#remove points where locust weren't found
locust_Eth<-locust_Eth %>% 
  dplyr::filter(LOCPRESENT == 1)
table(locust_Eth$LOCPRESENT)
locust_Eth_backup<-locust_Eth
locust_Eth<-locust_Eth[,-c(3:ncol(locust_Eth))]
names(locust_Eth)<-c('lon', 'lat')

Locust_Eth_spatial<-SpatialPoints(locust_Eth)

levelplot(prediction_eth$prediction_logistic, margin=FALSE, col.regions=viridis, at=seq(0, 1, len=100)) +
  latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col="red" , alpha=.3))

levelplot(prediction_eth$prediction_raw, margin=FALSE, col.regions=viridis, at=seq(0, 1, len=100)) +
  latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col="red",alpha=.3))

levelplot(prediction_eth$prediction_cloglog, margin=FALSE, col.regions=viridis, at=seq(0, 1, len=100)) +
  latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col="red", alpha=.3))

#Check out lambda values
parse_lambdas(maxent_model2)

writeRaster(prediction_eth$prediction_logistic, "rasterData/Ethiopia_predion_logistic.tif", format="GTiff")

#make some backups to work with
locust_Eth_backup<-locust_Eth



# get all values of 1 which for this dataset is all of them. Then make then into coordinates
occur.ras <- rasterize(locust_Eth, bio4_eth, 1)
occur.ras
crs(occur.ras)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
plot(occur.ras)


pres.locs <- coordinates(occur.ras)

head(locust_Eth[,1])
head(pres.locs[,1])
head(pres.locs[,2])
head(pres.locs)
nrow(pres.locs)
ncol(pres.locs)

#create a density map so we can sample unbiased locations
dens <- kde2d(locust_Eth[,1], locust_Eth[,2], n = c(nrow(occur.ras), ncol(occur.ras)), lims = c(extent(Ethiopia_predictors)[1], extent(Ethiopia_predictors)[2], extent(Ethiopia_predictors)[3], extent(Ethiopia_predictors)[4]))
dens.ras <- raster(dens, Ethiopia_predictors)
dens.ras2 <- resample(dens.ras, Ethiopia_predictors)
plot(dens.ras)
plot(dens.ras2)

writeRaster(dens.ras2, "biasfile_train.asc", overwrite = TRUE)

#check how many potential background points you have available

length(which(!is.na(values(subset(Ethiopia_predictors, 1)))))

#create 10,000 random background points. bg is using a bais raster file that we created above. bg_notCorrected is just random within the raster boundary

bg <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(Ethiopia_predictors, 1)))), 5000, prob=values(dens.ras2)[!is.na(values(subset(Ethiopia_predictors, 1)))]))
bg_notCorrected <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(Ethiopia_predictors, 1)))), 5000))

bg.ras <- rasterize(bg, bio4_eth,1)
plot(bg.ras)
bg_notC.ras <- rasterize(bg_notCorrected, bio4_eth,1)
plot(bg_notC.ras)

#evaluate how well the model does on the random and corrected points
eval_notCorrect<-dismo::evaluate(p=Locust_Eth_spatial ,a=bg_notCorrected, model=maxent_model2, Ethiopia_predictors)
plot(eval_notCorrect,"ROC")
boxplot(eval_notCorrect)

eval_corrected<-dismo::evaluate(p=Locust_Eth_spatial,a=bg, model=maxent_model2, Ethiopia_predictors)
plot(eval_corrected,"ROC")
boxplot(eval_corrected)

#plot limiting factors
lim <- limiting(Ethiopia_predictors, maxent_model2)
levelplot(lim, col.regions=rainbow) +
  latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col=1))

#plot the logistic map with a more useful cutoff to show where Locust might occur. The .05 and 1 can be changed to represent the model

levelplot(prediction_eth$prediction_logistic, margin=FALSE, col.regions=viridis, at=seq(0.05, 1, len=100)) +
  latticeExtra::layer(sp.points(Locust_Eth_spatial, pch=20, col=1))
