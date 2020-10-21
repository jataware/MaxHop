#map resutls
library(raster)
library(rgdal)
ras1<- raster("maxent_Ethiopia_precipChange=0.15tempChange=-0.15.tif")
plot(ras1)

rasNull<- raster("maxent_Ethiopia_precipChange=0tempChange=0.tif")
plot(rasNull)
title("Ethiopia: Precip_Δ=0, Temp_Δ=0")
ras.8<- raster("maxent_Ethiopia_precipChange=0.8tempChange=0.2.tif")
plot(ras.8)
title("Ethiopia: Precip_Δ=0.8, Temp_Δ=0.2")

difRaster<-ras1-rasNull
plot(difRaster)
title('Ethiopia: Difference Between Scenarios')




saNull<-raster('maxent_SaudiArabia_precipChange=0tempChange=0.tif')
saIncrease<-raster('maxent_SaudiArabia_precipChange=0.15tempChange=-0.15.tif')
saDecrease<-raster('maxent_SaudiArabia_precipChange=-0.15tempChange=0.15.tif')
difSA<-saIncrease-saNull
difSa2<-saDecrease-saNull
plot(difSA)
plot(difSa2)
