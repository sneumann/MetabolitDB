#setwd("C:/Users/Patrik/Desktop/testdir/")
#get all file names
fnames <- list.files("C:/Users/Patrik/Desktop/testdir/", full.names = T)

#read all tables into one dataframe
metabolitesDB <- do.call(rbind, lapply(fnames, read.table, sep="\t"))
