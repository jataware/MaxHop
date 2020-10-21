#command line run model
#an example run would be
#Rscript maxent_cl.R --country=Ethiopia --annualPrecipIncrease=.25 --meanTempIncrease=.5 --format=GTiff

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

#get arguments from cl
args <- commandArgs(trailingOnly = TRUE)

#flag for --annualPrecipIncrease
if(length(grep('--annualPrecipIncrease*', args, value = TRUE))==1){
  precInc <- as.numeric(strsplit(grep('--annualPrecipIncrease*', args, value = TRUE), split = '=')[[1]][[2]])
}else{
  precInc<-0
}


if(length(grep('meanTempIncrease*', args, value = TRUE))==1){
  aveTemp <- as.numeric(strsplit(grep('--meanTempIncrease*', args, value = TRUE), split = '=')[[1]][[2]])
}else{
  aveTemp<-0
}


if(length(grep('--county*', args, value = TRUE))==1){
  country <- toString(strsplit(grep('--county*', args, value = TRUE), split = '=')[[1]][[2]])
}else{
  country<-"Ethiopia"
}

if(length(grep('--format*', args, value = TRUE))==1){
  file.out <- toString(strsplit(grep('--format*', args, value = TRUE), split = '=')[[1]][[2]])
}else{
  file.out<-"GTiff"
}


#print out flag info
print("Flag info:")
print("Percent increase in Annual Precipitation")
precInc
print("Percent increase in Mean Temperature of Warmest Quarter")
aveTemp
print("Country to project model")
country
print("end of flag info.")

#load locust data
#locust_file_path<-paste0('hopper_data/',country, '_hoppers.csv',sep="")
#locust_Eth <- read.csv(locust_file_path ,header=TRUE, sep=',')


#load pretrained maxent model 
maxent_model<-readRDS("model/maxent_locust_model_WestAfrica10-15-2020")

#create paths to load rasters
bio4_filePath<-paste0('rasters/',country,"_bio4.asc", sep="")
bio8_filePath<-paste0('rasters/',country,"_bio8.asc", sep="")
bio10_filePath<-paste0('rasters/',country,"_bio10.asc", sep="")
bio12_filePath<-paste0('rasters/',country,"_bio12.asc", sep="")
clay_filePath<-paste0('rasters/',country,'_CLYPPT_M_sl2_250m_ll.asc', sep="")
sand_filePath<-paste0('rasters/',country,'_SNDPPT_M_sl2_250m_ll.asc', sep="")

#load rasters
bio4 <- raster(bio4_filePath)
bio8 <- raster(bio8_filePath)
bio10 <- raster(bio10_filePath)
bio12 <- raster(bio12_filePath)
clay <- raster(clay_filePath)
sand <- raster(sand_filePath)

#mutate raster based on flags
bio10_mutated<-calc(bio10, function(x)(x*aveTemp)+x)
bio12_mutated<-calc(bio12, function(x) (x * precInc)+x)

#create raster stack
predictors<-stack(bio4, bio8, bio10_mutated, bio12_mutated, clay, sand)
crs(predictors)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
names(predictors)<-c("WestAfrica_training_bio4", "WestAfrica_training_bio8", "WestAfrica_training_bio10", "WestAfrica_training_bio12", "WestAfrica_CLYPPT_M_sl2_250m_ll" , "WestAfrica_SNDPPT_M_sl2_250m_ll")

#project model onto stack
prediction<-rmaxent::project(maxent_model, predictors)
prediction_log<-prediction$prediction_logistic

if(file.out == "GTiff"){
  rastername=paste0('output/', 'maxent_', country, "_precipChange=",precInc, "tempChange=", aveTemp
, ".tiff", sep="" )
  writeRaster(prediction_log, rastername, format="GTiff", overwrite=T, NAflag=-9999 )
  
}else if(file.out == "ascii"){
  rastername=paste0('output/','maxent_', country, "_precipChange=",precInc, "tempChange=", aveTemp
                    , ".asc", sep="" )
  writeRaster(prediction_log, rastername, format="ascii", overwrite=T, NAflag=-9999 )
  
}else{
  print("File type not supported")
}


print('done')


