get_user_data <- function(userID=NULL,generation=NULL,suspect=NULL,sys_id=NULL) {  
  
  
  # Select which items to get
  query <- list()    
  
  if(!is.null(userID)){
    query[["userID"]] <- userID
  }
  
  if(!is.null(generation)){
    query[["generation"]] <- generation
  }
  
  
  if(!is.null(suspect)){
    query[["suspect"]] <- suspect
  }
  
  if(!is.null(sys_id)){
    if(length(sys_id)>1){
      query[["sys_id"]] <- list('$in'=sys_id)
    }else{
      query[["sys_id"]] <- sys_id
    }
  }
  
  
  # Select which columns/fields to get
  fields <- list()
  fields_to_get=c("_id","sys_id","name","pubchem","inchi","time","userID","username","generation","suspect")
  
  
  if(!is.null(generation)){
    if(generation==0L){
      fields_to_get = c(fields_to_get,"recorded_rt")
    }else{
      fields_to_get = c(fields_to_get,c("predicted_rt","ci_lower","ci_upper"))
    }
  }else{
    fields_to_get = c(fields_to_get,"recorded_rt",c("predicted_rt","ci_lower","ci_upper"))
  }
  
  
  
  for(i in 1:length(fields_to_get)){
    fields[[  fields_to_get[i]  ]]   <- 1L
  }
  
  
  
  
  
  # Read the data
  mongo <- PredRet_connect()
  data_all = mongo.find.all(mongo=mongo, ns=PredRet.env$namespaces$ns_rtdata,query = query,fields = fields  ,data.frame=T,mongo.oid2character=T)
  
  if(is.null(data_all)){
    del <- mongo.disconnect(mongo)
    del <- mongo.destroy(mongo)
    return(NULL)
  }
  
  row.names(data_all) <- seq(nrow(data_all))
  
  del <- mongo.disconnect(mongo)
  del <- mongo.destroy(mongo)
  
  
  # Take some data directly
  #data = data_all[,c("_id","sys_id","name","recorded_rt","pubchem","inchi","generation")]
  
  # Remove the time column
  data <- subset(data_all,select=-c(time))
  
  # Get correctly formatted time
  data = cbind.data.frame(data , `date added` = as.POSIXct(data_all[,"time"],origin="1970-01-01")     ,stringsAsFactors = F)
  
  
  # Get system name from system ID
  data = cbind.data.frame(data , system = sys_oid2name(data_all[,"sys_id"])          ,stringsAsFactors = F)
  
  
  
  
  return(data)
}
