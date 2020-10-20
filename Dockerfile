FROM r-base
RUN apt-get update && apt-get install -y --no-install-recommends
RUN apt-get install -y curl 
RUN apt-get install -y gdebi-core 
RUN apt-get install -y wget 
RUN apt-get install -y libcurl4-openssl-dev 
RUN apt-get  install -y libxml2-dev
RUN apt-get install -y libgdal-dev
RUN apt-get update && apt-get install -y \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    cmake 

RUN R -e 'install.packages(c("ggplot2"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("devtools"), dependencies=TRUE, repos="http://cran.rstudio.com/")'

RUN R -e 'install.packages(c("sp"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("magrittr"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("viridis"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("raster"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("ggplot2"), dependencies=TRUE, repos="http://cran.rstudio.com/")'
RUN R -e 'install.packages(c("rgdal"), dependencies=TRUE, repos="http://cran.rstudio.com/")'


CMD ["R","/usr/local/src/myscripts/myscript.r"]

COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts

CMD ["R","/usr/local/src/myscripts/maxent_cl.R"]