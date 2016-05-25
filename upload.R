setwd("C:/Users/Patrik/Desktop/data/")

#test reading of a csv and a tsv
csv <- read.table("C:/Users/Patrik/Desktop/data/Metabolite negativ H2O MAF.csv", sep=",") 
tsv <- read.table("C:/Users/Patrik/Desktop/data/Metabolite negativ H2O MAF.tsv", sep="\t")
csvH <- read.table("C:/Users/Patrik/Desktop/data/Metabolite negativ H2O MAF.csv", sep=",", header=T) 
tsvH <- read.table("C:/Users/Patrik/Desktop/data/Metabolite negativ H2O MAF.tsv", sep="\t", header=T)

#set vector of Predret-colnames, changes are PubChem, Compound and rt
true_colnames <- c("PubChem","chemical_formula","smiles","inchi","Compound","mass_to_charge","fragmentation","charge","rt","taxid","species","database","database_version","reliability","uri","search_engine","search_engine_score","modifications","smallmolecule_abundance_sub","smallmolecule_abundance_stdev_sub","smallmolecule_abundance_std_error_sub"
)

#set the colnames
colnames(csv) <- true_colnames
colnames(tsv) <- true_colnames

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

PredRet_upload_CSV(data) {
  # Convert data.frame to bson
  bson_data = mongo.bson.from.df(data_cleaned()$data)
  
  
  # add to table
  mongo <- PredRet_connect()
  wrote = mongo.insert.batch(mongo, PredRet.env$namespaces$ns_rtdata,
                             bson_data)
  del <- mongo.disconnect(mongo)
  del <- mongo.destroy(mongo)
}