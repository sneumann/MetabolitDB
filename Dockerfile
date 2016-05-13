
FROM rocker/rstudio

MAINTAINER sneumann@ipb-halle.de

# nuke cache dirs before installing pkgs; tip from Dirk E fixes broken img
RUN  rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*

RUN apt-get update --fix-missing

RUN apt-get -y install libssh2-1-dev



### naechste 3 sachen waren nicht auskommentiert. Fehler irgendwo im ADD
#ADD install.R /tmp/

#RUN R -f /tmp/install.R && \
  #  echo "library(BiocInstaller)" > $HOME/.Rprofile
 
RUN R -e "install.packages('devtools')"

RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite('pcaMethods', ask=FALSE)"

RUN R -e "library(devtools); install_github('mongosoup/rmongodb')"

RUN R -e "library(devtools); install_github('stanstrup/Rplot.extra');install_github('stanstrup/massageR');install_github('stanstrup/PredRet', subdir='PredRetR')"
