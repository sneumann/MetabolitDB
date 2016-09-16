# MetabolitDB
Metabolite DB for Research Group Module ("Forschungsgruppenmodul")

TODO:
- get mongo-dump working
    -   find out what the error messages from the docker shell mean
    -   fix these problems
- after working mongo dump: see if everything works as planned, which means:
    -   data are stored and saved correctly in between sessions (PC restart)
    -   predret-shiny systems are shown

Running Mongo:
- docker run --name predret-mongo -v $PWD/datadir:/data/db -p 27017:27017 -d mongo:latest

Running the Docker-Files:
- go to directory where Dockerfile is located (with the Docker Console, tested on Windows10)
- execute 'docker build -t sneumann/predret:snapshot .'
- docker run -d --link predret-mongo:predret-mongo -p 8788:3838 sneumann/predret:snapshot 

- The rocker/rstudio default login credentials are:
    username: rstudio
    password: rstudio

