FROM r-base
RUN apt-get update && apt-get install -y \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    cmake \
    curl \
    wget \
    libcurl4-openssl-dev \
    libgdal-dev


RUN R -e 'install.packages(c("devtools", "magrittr", "viridis", "raster", "rgdal"), dependencies=TRUE, repos="http://cran.rstudio.com/")'




COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts

RUN Rscript ./myscript.R

#CMD ["R","/usr/local/src/myscripts/maxent_cl.R"]