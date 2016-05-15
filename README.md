# MetabolitDB
Metabolite DB for Research Group Module ("Forschungsgruppenmodul")

TODO:
- incorporate further data
- Docker Mongo
- Docker bioconductor
- link the Mongo+bioconductor Docker
- manage to get PredRet working on the bioconductor Docker (in R)

Running Mongo:
- docker run --name predret-mongo -v $PWD/datadir:/data/db -p 27017:27017 -d mongo:latest

Running the Docker-Files:
- go to directory where Dockerfile is located (with the Docker Console, tested on Windows10)
- execute 'docker build -t sneumann/predret:snapshot .'
- docker run -d --link predret-mongo:predret-mongo -p 8788:3838 sneumann/predret:snapshot 

- The rocker/rstudio default login credentials are:
    username: rstudio
    password: rstudio

