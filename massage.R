massage <- function (input) {
  
  # get data
  data = input
  colnames = tolower(colnames(data))
  cols_to_get = c("compound","rt","method","pubchem","inchi")
  select=rep(NA,length(cols_to_get))
  for(i in 1:length(cols_to_get)){
    select[i] = grep(cols_to_get[i],colnames,fixed = T)[1]
  }
  
  # Make sure data is unique
  data   =    data[,select[!is.na(select)]]
  data = unique(data)
  
  colnames(data) = c("name","recorded_rt","system_name","pubchem","inchi")[!is.na(select)]
  
  # Make sure there is a pubchem column
  if(!any(colnames(data)=="pubchem")){
    data = cbind.data.frame(data,pubchem=NA)
  }
  
  # Make sure there is a pubchem inchi
  if(!any(colnames(data)=="inchi")){
    data = cbind.data.frame(data,inchi=NA)
  }
  
  # Make sure pubchem id is treated as integer
  if(any(colnames(data)=="pubchem")){
    data[,"pubchem"] = as.integer(data[,"pubchem"])
  }
  
  # Make sure rt is treated as numeric
  data[,"recorded_rt"] = as.numeric(data[,"recorded_rt"])
  
  # Test whether there are data without rt and exit if that is the case
  no_rt = is.na(data[,"recorded_rt"]) | is.nan(data[,"recorded_rt"])
  if(any(no_rt)) {paste("Error: Not all entries contain a retention time."); return}
  
  data =    data[!(no_rt),,drop=F]
  
  # Get InChI from the PubChem CIDs
  if(any(colnames(data)=="inchi")){
    # Specify no_inchi
    no_inchi = !grepl("InChI",data[,"inchi"],fixed=T)   &    !(is.na(data[,"pubchem"]) | is.nan(data[,"pubchem"]))
    # Use CTSgetR to get the InChIs
    data[no_inchi,"inchi"] = as.character(CTSgetR(id=data[no_inchi,"pubchem"], from="PubChem CID", to="InChI Code")[,2])
    
    # ATTENTION: If, for some reason, the above line with CTSgetR does not work,
    # instead use the line below to still be able to upload the data (only with
    # missing InChi)
    #data[no_inchi,"inchi"] = 0
  }
  
  time = Sys.time()
  
  # Set system to IPB_Halle
  halle <- "IPB_Halle"
  sys_name = as.character(unlist(lapply(systems_in_db(),function(x) x$system_name)))  
  sys_id = unlist(lapply(systems_in_db(),function(x) as.character.mongo.oid(x$`_id`))  )
  idx = match(halle,sys_name)
  sys_id = sys_id[idx] # "53d78bc07f4ebee5eadbbf06"
  
  if(any(colnames(data)=="system_name")){
    data = subset(data,select = -system_name) # Remove names and rely only on system ids  
  }
  
  # Connect all to one dataframe
  data =data.frame(sys_id,data,time=time, userID=as.integer(1234),username=as.character("Test"),generation=as.integer(0),stringsAsFactors= FALSE)
  
  # Add columns of predicted rt, cis and suspect
  data <- cbind.data.frame(data,predicted_rt=0,ci_lower=0,ci_upper=0,suspect=FALSE)
  
  # Return the dataframe
  out = data
  return(out)
  
  
}