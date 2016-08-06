massage <- function (input) {
  data = input
  
  colnames = tolower(colnames(data))
  cols_to_get = c("compound","rt","method","pubchem","inchi")
  select=rep(NA,length(cols_to_get))
  for(i in 1:length(cols_to_get)){
    select[i] = grep(cols_to_get[i],colnames,fixed = T)[1]
  }
  
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
  
  no_rt = is.na(data[,"recorded_rt"]) | is.nan(data[,"recorded_rt"])
  if(any(no_rt)) {paste("Error: Not all entries contain a retention time."); return}
  
  data =    data[!(no_rt),,drop=F]
  
  if(any(colnames(data)=="inchi")){
    no_inchi = !grepl("InChI",data[,"inchi"],fixed=T)   &    !(is.na(data[,"pubchem"]) | is.nan(data[,"pubchem"]))
    #next line does not work for some reason
    #temp_data[no_inchi,"inchi"] = pubchem2inchi(    temp_data[no_inchi,"pubchem"]       )
    data[no_inchi,"inchi"] = "NA"
  }
  
  time = Sys.time()
  
  halle <- "IPB-Halle"
  sys_name = halle
  sys_id = unlist(lapply(systems_in_db(),function(x) as.character.mongo.oid(x$`_id`))  )
  #idx = match(data[,"system_name"],sys_name)
  idx = halle
  
  sys_id = sys_id[idx] # "53d78bc07f4ebee5eadbbf06"
  
  if(any(colnames(data)=="system_name")){
    data = subset(data,select = -system_name) # Remove names and rely only on system ids  
  }
  
  data =data.frame(sys_id,data,time=time,userID=as.integer(1234),username=as.character("Test"),generation=as.integer(0),stringsAsFactors= FALSE)
  
  if(!is.na(data)){
    data <- cbind.data.frame(data,predicted_rt=as.numeric(NA),ci_lower=as.numeric(NA),ci_upper=as.numeric(NA),suspect=FALSE)
  }
  
  out = data
  return(out)
  
  
}