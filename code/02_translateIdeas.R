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
docdir<-file.path(
  homedir,
  "documentation"
)
setwd(docdir); dir()
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

#fill in all missing ideas
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
  #print(myvar)
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
}) %>% unlist %>% unique
fvarsdf<-lapply(ideas,function(idea) {
  #idea<-"Household size"
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
  "wikisurvey_clean.csv",
  stringsAsFactors=F
)

#and merge w/ the original 
intersect(
  names(wikidf),
  names(fvarsdf)
)
fulldf<-merge(
  wikidf,
  fvarsdf,
  all=T
)

#check this is complete?
tmp<-is.na(fulldf$score)
if(sum(tmp)>0)
  stop()

###########################################
###########################################

#finalize
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

#spread to make it easy 
fulldf<-tidyr::spread(
  fulldf,
  type,
  score
)

#add a note marking the originals
wikidir<-file.path(
  homedir,
  "wiki_surveys"
)
setwd(wikidir); dir()
tmptext<-readLines('setup.txt')[25:51]
tmptext[27]<-"Teacher quality"

#mark these as originals
tmp<-tolower(fulldf$idea)%in%
  tolower(tmptext)
sum(tmp); sum(!tmp)
fulldf$user.submitted<-NULL
fulldf$user.submitted<-T
fulldf$user.submitted[tmp]<-F

#save out
setwd(outputdir)
colorder<-c(
  "outcome",
  "idea",
  "user.submitted",
  "ffvar",
  "experts",
  "mturkers"
)
write.csv(
  fulldf[,colorder],
  "ffvars_scored.csv",
  row.names=F
)

###########################################
###########################################

