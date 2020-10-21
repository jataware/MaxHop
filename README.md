# cl_maxent_locust
Run locust maxent model from the command line

An example of how to run the docker container with modified parameters:
docker run -v ~/cl_maxent_locust/output:/usr/local/src/myscripts/output  cl_maxent_locust_docker [command] "--country=Sudan" "--annualPrecipIncrease=.4" "--meanTempIncrease=.2"  "--format=GTiff"

This runs the container with a volume attached locally in the output folder. 
The cl_maxent_locust_docker is the image to be run.
The [command] lets docker know you want to overwrite the CMD code in the Dockerfile.
The parameters after are in quotes and those are parsed by the r code, which determines which country, how much to increase or decrease the Annual Precipitation (--annualPrecipIncrease) or Mean Temperature of Warmest Quarter (--meanTempIncrease), and the type of file output ('GTiff' or 'ascii')
