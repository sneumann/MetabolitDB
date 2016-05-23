
FROM rocker/rstudio

MAINTAINER sneumann@ipb-halle.de1

# nuke cache dirs before installing pkgs; tip from Dirk E fixes broken img
RUN  rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*

RUN apt-get update --fix-missing

RUN apt-get -y install openbabel libnetcdf-dev libssh2-1-dev r-cran-rjava r-cran-gridextra r-cran-xml --fix-missing
 
RUN R -e "install.packages(c('devtools', 'rmarkdown', 'xlsx', 'DT'))"

RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite(c('pcaMethods', 'Rdisop', 'xcms', 'CAMERA'), ask=FALSE)"

RUN R -e "library(devtools); install_github('mongosoup/rmongodb')"

RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite(c('ChemmineR'), ask=FALSE)"

RUN R -e "library(devtools); install_github('stanstrup/Rplot.extra');"

RUN R -e "library(devtools); install_github('dgrapov/CTSgetR');"

RUN R -e "library(devtools); install_github('stanstrup/obabel2R')"

RUN R -e "library(devtools); install_github('stanstrup/chemhelper')"

RUN R -e "library(devtools); install_github('stanstrup/massageR');install_github('stanstrup/rmongodb.quick')"

RUN apt-get -y install cmake

# Install and configure shiny-server
WORKDIR /usr/src
RUN git clone https://github.com/rstudio/shiny-server.git
WORKDIR /usr/src/shiny-server
RUN mkdir tmp
WORKDIR /usr/src/shiny-server/tmp
RUN DIR=`pwd`; PATH=$DIR/../bin:$PATH; PYTHON=`which python`; cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../; make; mkdir ../build; (cd .. && ./bin/npm --python="$PYTHON" rebuild); (cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js --python="$PYTHON" rebuild)
RUN make install
RUN ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server
RUN useradd -r -m shiny
RUN mkdir -p /var/log/shiny-server
RUN mkdir -p /srv/shiny-server
RUN mkdir -p /var/lib/shiny-server
RUN chown shiny /var/log/shiny-server
RUN mkdir -p /etc/shiny-server
RUN wget https://raw.github.com/rstudio/shiny-server/master/config/upstart/shiny-server.conf -O /etc/init/shiny-server.conf
RUN cp -r /usr/src/shiny-server/samples/* /srv/shiny-server/
RUN wget https://raw.githubusercontent.com/rstudio/shiny-server/master/config/default.config -O /etc/shiny-server/shiny-server.conf

RUN mkdir -p /var/log/shiny-server ; chown shiny /var/log/shiny-server 

## Install the current versions, just to get Dependencies installed 
## automagically
RUN R -e "install.packages(c('shiny', 'shinyBS'))"

COPY shiny_0.12.1.tar.gz /tmp/shiny_0.12.1.tar.gz
RUN R CMD INSTALL /tmp/shiny_0.12.1.tar.gz

COPY shinyBS_0.20.tar.gz /tmp/shinyBS_0.20.tar.gz
RUN R CMD INSTALL /tmp/shinyBS_0.20.tar.gz

RUN R -e "library(devtools); install_github('stanstrup/PredRet', subdir='PredRetR')"
#RUN R -e "library(devtools); install_github('sneumann/PredRet', subdir='PredRetR') "

WORKDIR /
RUN git clone https://github.com/stanstrup/PredRet.git
#RUN git clone https://github.com/sneumann/PredRet.git

# Using official github repository
RUN mv /srv/shiny-server /srv/shiny-server_orig

WORKDIR /srv
RUN mkdir /srv/shiny-server/
RUN mv /PredRet/scripts  /srv/shiny-server/
RUN mv /PredRet/retdb  /srv/shiny-server/
RUN mv /PredRet/retdb_admin /srv/shiny-server/

RUN R -e "library(devtools); install_github('ramnathv/rCharts')"
RUN R -e "library(devtools); install_github('rstudio/shiny-incubator', ref='5b4f15454e23572cce014b52f7c93026da02726c')"

# Expose port
EXPOSE 3838

# Define Entry point script
WORKDIR /tmp
COPY PredRet.conf PredRet.conf
COPY PredRet.conf /srv/shiny-server/retdb
COPY PredRet.conf /srv/shiny-server/retdb_admin

ENTRYPOINT ["/usr/bin/shiny-server","--pidfile=/var/run/shiny-server.pid"]

## Start with a local copy: mongodump -h "predret.org" -u "predret_readonly" -p "readonly" --db "predret"

