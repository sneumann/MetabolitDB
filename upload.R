setwd("C:/Users/Patrik/Desktop/data/")
setwd("/data/")

library(PredRetR)
PredRet.env$mongo$host <- "predret-mongo"
PredRet.env$mongo$username <- ""
PredRet.env$mongo$password <- ""

#test reading of a csv and a tsv
csv <- read.table("/data/Metabolite negativ H2O MAF.csv", sep=",") 
tsv <- read.table("/data/Metabolite negativ H2O MAF.tsv", sep="\t")
csvH <- read.table("/data/Metabolite negativ H2O MAF.csv", sep=",", header=T) 
tsvH <- read.table("/data/Metabolite positiv H2O MAF.tsv", sep="\t", header=T)
data <- read.table("/data/m_MTBLS160_Exudate_metabolite_profiling_mass_spectrometry_targeted_v2_maf.tsv", sep="\t", header=T)
#set vector of Predret-colnames, changes are PubChem, Compound and rt
#true_colnames <- c("PubChem","chemical_formula","smiles","inchi","Compound","mass_to_charge","fragmentation","charge","rt","taxid","species","database","database_version","reliability","uri","search_engine","search_engine_score","modifications","smallmolecule_abundance_sub","smallmolecule_abundance_stdev_sub","smallmolecule_abundance_std_error_sub"
#)
subdata<-tsvH[tsvH$database=='PubChem', ]

#translating ChEBI to PubChem CID:
##library(devtools)
##install_github(repo="CTSgetR", username="dgrapov", ref="simple")
#library(CTSgetR)
#values <- CTSgetR(id=subdata$database_identifier,from="ChEBI",to="PubChem CID")
#subdata$database_identifier<-values$value

colnames(subdata) <- sub('database_identifier','PubChem',colnames(subdata))
colnames(subdata) <- sub('metabolite_identification','Compound',colnames(subdata))
colnames(subdata) <- sub('retention_time','rt',colnames(subdata))
#set the colnames
#colnames(csv) <- true_colnames
#colnames(tsv) <- true_colnames

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
#TODO

PredRet_upload_CSV <- function(data) {
  # Convert data.frame to bson
  bson_data = mongo.bson.from.df(data)
  
  
  # add to table
  mongo <- PredRet_connect()
  wrote = mongo.insert.batch(mongo, PredRet.env$namespaces$ns_rtdata,
                             bson_data)
  del <- mongo.disconnect(mongo)
  del <- mongo.destroy(mongo)
}

get_systems()
#PredRet.env$namespaces

mongo <- PredRet_connect()
#fields = mongo.bson.buffer.create()
#mongo.bson.buffer.append(fields, "_id", 1L)
#mongo.bson.buffer.append(fields, "sys_id", 1L)
#mongo.bson.buffer.append(fields, "system_name", 1L)
#mongo.bson.buffer.append(fields, "system_desc", 1L)
#mongo.bson.buffer.append(fields, "userID", 1L)
#mongo.bson.buffer.append(fields, "username", 1L)
#mongo.bson.buffer.append(fields, "system_eluent", 1L)
#mongo.bson.buffer.append(fields, "system_eluent_pH", 1L)
#mongo.bson.buffer.append(fields, "system_eluent_additive", 1L)
#mongo.bson.buffer.append(fields, "system_column", 1L)
#mongo.bson.buffer.append(fields, "system_column_type", 1L)
#mongo.bson.buffer.append(fields, "system_ref", 1L)
#fields = mongo.bson.from.buffer(fields)
#data_back = mongo.find.all(mongo, ns = PredRet.env$namespaces$ns_rtdata, fields = fields, mongo.oid2character = TRUE)
#del <- mongo.disconnect(mongo)
#del <- mongo.destroy(mongo)
#return(data_back)
# mongo.find.one(mongo, ns=PredRet.env$namespaces$n_rtdata) klappt scheinbar?

# funktioniert teilweise?
#testcursor <- mongo.find(mongo, ns=PredRet.env$namespaces$ns_rtdata)
#mongo.cursor.to.data.frame(testcursor)
