rm(list=ls()) 

#setwd
homedir<-file.path(
  "c:",
  "users",
  "adaner",
  "dropbox",
  "school",
  "sicss",
  "collective_wisdom"
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
  "wiki_surveys"
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

###########################################
###########################################

#we get the list of unique ideas, 
#and output this to a googledoc (via .txt file)

tmpdir<-file.path(
  "c:",
  "users",
  "adaner",
  "desktop"
)
setwd(
  deskdir
); 
dir()
unique.ideas<-fulldf$idea.text %>% unique
write(unique.ideas,"uniqueideas.txt")

#this google doc is then used to link each idea to ffvar
