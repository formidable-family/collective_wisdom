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

#get wikisurvey data
wikidir<-file.path(
  homedir,
  "wikisurvey",
  "wiki_results_6_29"
)
setwd(wikidir); dir()

#recent results
types<-c(
  "experts",
  "mturks"
)

fulldf<-lapply(types,function(type) {
  #type<-types[1]
  tmpdir<-file.path(
    wikidir,
    type
  )
  setwd(tmpdir); dir()
  tmp<-str_detect(dir(),"\\.csv") & 
    str_detect(dir(),"ideas")
  csvfiles<-dir()[tmp]
  bigdf<-lapply(csvfiles,function(thisfile) {
    thisdf<-read.csv(thisfile,stringsAsFactors=F)
    thisdf$filename<-thisfile
    thisdf
  }) %>% rbind.fill
  bigdf$type<-type
  bigdf
}) %>% rbind.fill

###########################################
###########################################

#tolower
names(fulldf)<-tolower(names(fulldf))

#get 
fulldf$outcome<-str_replace(
  fulldf$filename,
  "wikisurvey\\_",
  ""
) %>% str_replace(
  "\\_ideas.csv",
  ""
)

#trim to active outcomes
fulldf<-fulldf[fulldf$active,]

#trim
keepcols<-c(
  "idea.text",
  "outcome",
  "score",
  "type",
  "user.submitted"
)
fulldf<-fulldf[,keepcols]
names(fulldf)[1]<-"idea"

###########################################
###########################################

#output wikidf
outputdir<-file.path(
  homedir,
  "output"
)
setwd(outputdir)
write.csv(
  fulldf,
  "clean_wikisurvey.csv",
  row.names=F
)

###########################################
###########################################

# #output unique ideas for Google Doc
# deskdir<-file.path(
#   "c:",
#   "users",
#   "adaner",
#   "desktop"
# )
# setwd(
#   deskdir
# ); dir()
# unique.ideas<-fulldf$idea.text %>% unique
# write(unique.ideas,"uniqueideas.txt")

###########################################
###########################################
