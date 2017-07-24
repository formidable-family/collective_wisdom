rm(list=ls()) 

#setwd
homedir<-file.path(
  "c:",
  "users",
  "adaner",
  "dropbox",
  "school",
  "sicss",
  "fragile_families"
)

#packages
require(stringr)
require(plyr)
require(dplyr)
require(tidyr)
require(data.table)

###########################################
###########################################

#read in Allie's files
setwd(homedir); dir()
tablesdir<-file.path(
  homedir,
  "tables"
)
setwd(tablesdir)

csvs<-dir()
tmpseq.i<-seq_along(csvs)
sigvars.list<-lapply(tmpseq.i,function(i) {
  #i<-34
  #j<-125
  print(i)
  thiscsv<-csvs[i]
  tmpfile<-readLines(thiscsv)
  tmp<-length(tmpfile)==0
  if(!tmp) {
    thisfile<-read.csv(
      thiscsv,
      stringsAsFactors=F,
      header=F
    )
    tmpseq.j<-1:nrow(thisfile)
    keepers<-sapply(tmpseq.j,function(j) {
      #print(j)
      #print("###")
      #j<-25
      thisrow<-thisfile[j,]
      tmpregex<-"\\*"
      sum(str_detect(
        thisrow,
        tmpregex
      ))>0
    })
    sigfile<-thisfile[keepers,]
    tmpclass<-class(sigfile)
    if(tmpclass=="data.frame") {
      sigvars<-apply(sigfile,1,paste0,collapse=" ")
    } else if(tmpclass=="character") {
      sigvars<-sigfile
    }
  } else {
    sigvars<-NULL
  }
  sigvars
})

###########################################
###########################################

#
sigvars<-unlist(sigvars.list)

#clean up
sigvars<-tolower(sigvars)

# keep only letters
tmplist<-str_extract_all(
  sigvars,
  "[a-z]|\\s"
)
tmplist<-lapply(
  tmplist,
  paste0,
  collapse=""
)
sigvars<-unlist(tmplist)

#
sigvars<-str_replace(
  sigvars,
  "^\\s+|\\s+$",
  ""
) %>% unique

###########################################
###########################################

#lemmatizing
library(textstem)
sigvars<-lemmatize_strings(sigvars)

#remove stop words
library(tm)


#tm gives us english stopwords

#we also want some stats stopwords


#stopwords('en')
stopwords_regex <- paste(
  stopwords('en'), 
  collapse = '\\b|\\b'
)
stopwords_regex <- paste0(
  '\\b', stopwords_regex, '\\b'
  )
sigvars <- str_replace_all(
  sigvars,
  stopwords_regex,
  ""
)
sigvars<-str_replace(
  sigvars,
  "^\\s+|\\s+$",
  ""
)
# sigvars<-str_replace_all(
#   sigvars,
#   "\\s+","\\s"
# )

#make unique again
sigvars<-unique(sigvars)

deskdir<-file.path(
  "c:",
  "users",
  "adaner",
  "desktop"
)
setwd(deskdir)
write(sigvars,"sigvars.txt")