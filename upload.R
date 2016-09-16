#setwd("C:/Users/Patrik/Desktop/data/")
#setwd("/data/")

# Necessary preparation of libraries etc
library(PredRetR)
library(chemhelper)
install_github("dgrapov/CTSgetR")
library(CTSgetR)
PredRet.env$mongo$host <- "predret-mongo"
PredRet.env$mongo$username <- ""
PredRet.env$mongo$password <- ""

# Get systems
systems_in_db <- function(){
  
  data_back <- get_systems()
  return(data_back)

}

# Makes all preprocessing prior to massage(data)
# Takes: *.tsv filepath (in this environment: /data/filename.tsv) of
#       a MAF-formatted TSV
# Returns: preprocessed dataframe with PredRet-compatible colnames and only
#         those entries with a PubChem identifier
preproc <- function(filein) {

  data <- read.table(filein, sep="\t", header=T, stringsAsFactors = F)
  ix <- sapply(data, is.character)
  data[ix] <- lapply(data[ix], iconv, from="latin1")
  subdata<-data[data$database=='PubChem',]
  colnames(subdata) <- sub('database_identifier','PubChem',colnames(subdata))
  colnames(subdata) <- sub('metabolite_identification','Compound',colnames(subdata))
  colnames(subdata) <- sub('retention_time','rt',colnames(subdata))
  return(subdata)
  
}

# Uploads data to the predret database
# Takes:    the correct dataframe, which is a massaged (massage()), preprocessed
#           (preproc()) input in the form of a MAF File
# Returns:  Nothing; it just uploads the data 
PredRet_upload <- function(data) {
  
  # Convert data.frame to bson
  bson_data = mongo.bson.from.df(data)
  
  # Add to table
  mongo <- PredRet_connect() 
  wrote = mongo.insert.batch(mongo, PredRet.env$namespaces$ns_rtdata, bson_data)
  del <- mongo.disconnect(mongo)
  del <- mongo.destroy(mongo)
  
}

# View all data with these lines
alldata <- PredRetR:::get_user_data()
str(alldata)

# functions for producing a tsv and a csv file
to_tsv <- function(filein, fileout) {
  write.table(filein,file=paste(fileout,".tsv",sep=""),sep="\t",na="\"\"",col.names=FALSE,row.names=FALSE);
}

to_csv <- function(filein, fileout) {
  write.table(filein,file=paste(fileout,".csv",sep=""),sep=",",na="\"\"",col.names=FALSE,row.names=FALSE);
}

#needs a nicer error message, maybe some error catching optimization
convert_format <- function(filein, fileout, outtype) {
  if(as.character(outtype) == "tsv"){
    write.table(filein,file=paste(fileout,".csv",sep=""),sep=",",na="\"\"",col.names=FALSE,row.names=FALSE);
  }
  else if(as.character(outtype) == "csv"){
    write.table(filein,file=paste(fileout,".csv",sep=""),sep=",",na="\"\"",col.names=FALSE,row.names=FALSE);
  }
  else {print("Argument outtype needs to be  {\"tsv\"|\"csv\"}")}
}

#######################################################################
#     ATTENTION                                                       #
#     From here on, there are only old testing functions and lines    #
#######################################################################

# old testing lines for getting input tables
csv <- read.table("/data/Metabolite negativ H2O MAF.csv", sep=",") 
tsv <- read.table("/data/Metabolite negativ H2O MAF.tsv", sep="\t")
csvH <- read.table("/data/Metabolite negativ H2O MAF.csv", sep=",", header=T,  stringsAsFactors = F) 
tsvH <- read.table("/data/Metabolite positiv H2O MAF.tsv", sep="\t", header=T, stringsAsFactors = F)
data <- read.table("/data/m_MTBLS160_Exudate_metabolite_profiling_mass_spectrometry_targeted_v2_maf.tsv", sep="\t", header=T)

# old: only use lines with PubChem database
subdata<-tsvH[tsvH$database=='PubChem', ]

#translating ChEBI to PubChem CID:
##library(devtools)
##install_github(repo="CTSgetR", username="dgrapov", ref="simple")
#library(CTSgetR)
#values <- CTSgetR(id=subdata$database_identifier,from="ChEBI",to="PubChem CID")
#subdata$database_identifier<-values$value

# old: create correct colnames
colnames(subdata) <- sub('database_identifier','PubChem',colnames(subdata))
colnames(subdata) <- sub('metabolite_identification','Compound',colnames(subdata))
colnames(subdata) <- sub('retention_time','rt',colnames(subdata))

# old: Test dataframe
testcolnames <- c('ci_lower', 'ci_upper', 'generation', 'inchi', 'name', 'predicted_rt', 'pubchem', 'recorded_rt', 'suspect', 'sys_id', 'userID', 'username', 'time') 
#, 'system')
testcontent <- c(as.numeric(NA), as.numeric(NA), 0, as.character(NA), 'Testsubstanz', as.numeric(NA), 999999, 13, FALSE, sys_id, 1234, 'Test', time)
#, 'IPB_Halle')
testdf <- data.frame(testcontent)
testdf <- t(testdf)
colnames(testdf) <- testcolnames
View(testdf)

#uploaddata <- massage(subdata)
#sortiere spalten so wie input????
#uploaddata <- uploaddata[c(12,13,10,5,2,11,4,3,14,1,8,9,6,7)]

halle <- "IPB_Halle"
#check systems, for error searching purposes
get_systems()

#mongo connect to predret db
mongo <- PredRet_connect()

# funktioniert teilweise?
testcursor <- mongo.find.all(mongo, ns=PredRet.env$namespaces$ns_rtdata)
#rtdata_df <- mongo.cursor.to.data.frame(testcursor)
##########
###KLAPPT zum ansehen der daten
#d <- do.call(rbind, testcursor)
mongo <-PredRet_connect()
res <- mongo.find.all(mongo=mongo,ns=PredRet.env$namespaces$ns_rtdata)
head(res)
tail(res)