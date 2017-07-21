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

#read it in
outputdir<-file.path(
  homedir,
  "output"
)
setwd(outputdir); dir()
ideasdf<-read.csv(
  'ideas_translation.csv',
  stringsAsFactors=F
)

#for below, codebook also needed
codedf<-read.csv(
  'codebook.csv',
  stringsAsFactors=F
)

###########################################
###########################################

#rename vars
names(ideasdf)
names(ideasdf)<-c(
  "idea",
  "vardescription",
  "varname"
)

#fill in 
tmp<-ideasdf$idea==""
ideasdf$idea[tmp]<-NA
ideasdf$idea<-zoo::na.locf.default(
  ideasdf$idea
)

tmp<-is.na(ideasdf$idea)
if(sum(tmp)>0)
  stop()

#we need to loop through all unique vars
#obtain unique vars by splitting at slash/comma,
#and replacing asterixes with all matches
varnames<-unique(ideasdf$varname) %>%
  str_replace_all(
    "\\s",""
  )
varnames<-sapply(varnames,function(x) {
  str_split(x,",|/")
}) %>% 
  unlist %>%
  unname
varnames<-varnames[varnames!=""]

allvarsdf<-lapply(varnames,function(myvar) {
  #myvar<-"c**inpov"
  print(myvar)
  #get the idea text associated
  tmp<-str_detect(
    ideasdf$varname,
    fixed(myvar)
  )
  idea<-ideasdf$idea[tmp] %>%
    unique %>% paste0(
      collapse="~~~"
    )
  if(length(idea)!=1)
    stop()
  
  #is it a regex?
  isregex<-str_detect(myvar,"\\*")
  if(isregex) {
    myvar.regex<-str_replace_all(
      myvar,
      "\\*","."
    )
    tmp<-str_detect(
      codedf$varname,
      myvar.regex
    )
    returnvars<-codedf$varname[tmp]
  } else {
    tmp<-codedf$varname==myvar
    if(sum(tmp)==0) {
      returnvars<-NA
    } else if(sum(tmp)==1) {
      returnvars<-codedf$varname[tmp]
    } else {
      stop()
    }
  }
  ####
  data.frame(
    idea=idea,
    varname=myvar,
    ffvar=returnvars,
    stringsAsFactors=F
  )
}) %>% rbind.fill

#allvarsdf needs to be split into 
#unique ideas in rows, for merge
ideas<-allvarsdf$idea
ideas<-sapply(ideas,function(x) {
  str_split(x,"~~~")
}) %>% unique %>% unlist
allvarsdf<-lapply(ideas,function(idea) {
  #idea<-"School quality"
  tmp<-str_detect(allvarsdf$idea,idea)
  keepcols<-c(
    "varname",
    "ffvar"
  )
  returndf<-allvarsdf[tmp,keepcols]
  returndf$idea<-idea
  returndf
}) %>% rbind.fill

###########################################
###########################################

#merge in wikisurvey information
setwd(outputdir); dir()
wikidf<-read.csv(
  "clean_wikisurvey.csv",
  stringsAsFactors=F
)

#and get the original 
intersect(
  names(wikidf),
  names(allvarsdf)
)
head(wikidf); nrow(wikidf)
head(allvarsdf); nrow(allvarsdf)
fulldf<-merge(
  wikidf,
  allvarsdf,
  all=T
)

# #check
# wikidf$idea %>% unique %>% sort
# head(fulldf)
# 
# #check this is complete?
# tmp<-is.na(fulldf$score)
# fulldf$idea[tmp] %>% unique
# fulldf[tmp,]

###########################################
###########################################

#output
names(fulldf)
colorder<-c(
  "outcome",
  "idea",
  "ffvar",
  "score",
  "type"
)
roworder<-order(
  fulldf$outcome,
  fulldf$ffvar
)
fulldf<-fulldf[roworder,colorder]

#not sure why this is necessary, but..
fulldf<-unique(fulldf)

fulldf<-tidyr::spread(
  fulldf,
  type,
  score
)

#add a note for which are original
wikidir<-file.path(
  homedir,
  "wikisurvey"
)
setwd(wikidir); dir()
tmptext<-readLines('setup.txt')[25:51]
tmptext[27]<-"Teacher quality"

#mark these as originals
head(fulldf)
tmp<-tolower(fulldf$idea)%in%tolower(tmptext)
sum(tmp); sum(!tmp)
fulldf$user.submitted<-NULL
fulldf$user.submitted<-T
fulldf$user.submitted[tmp]<-F

setwd(outputdir)
write.csv(
  fulldf,
  "ffvars_scored.csv",
  row.names=F
)

###########################################
###########################################

