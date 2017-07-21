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

#emails
datadir<-file.path(
  homedir,
  "data"
)
setwd(datadir); dir()

df1<-read.csv(
  "Batch_2851292_batch_results.csv",
  stringsAsFactors=F
)
df2<-read.csv(
  "Batch_2851308_batch_results.csv",
  stringsAsFactors=F
)

#put it together
tmpdf<-rbind.fill(
  df1,
  df2
)
names(tmpdf)<-tolower(names(tmpdf))
tmpcols<-str_detect(
  names(tmpdf),
  "input|answer"
)
tmpdf<-tmpdf[,tmpcols]

names(tmpdf)<-str_replace(
  names(tmpdf),
  "input\\.|answer\\.",
  ""
)

#make empties missing
vars<-names(tmpdf)
for(var in vars) {
  tmpdf[[var]]<-str_replace(
    tmpdf[[var]],
    "^\\s+|\\s+$",
    ""
  )
  tmpdf[[var]][tmpdf[[var]]==""]<-NA
}

#fix the email addresses!
tmpdf$emailaddress<-tolower(
  tmpdf$emailaddress
)
tmpdf$emailaddress<-str_replace(
  tmpdf$emailaddress,
  "\\.$",""
)
tmpdf$emailaddress<-str_replace_all(
  tmpdf$emailaddress,
  "\\s",""
)

atcounter<-str_count(tmpdf$emailaddress,"@")
tmp<-atcounter>1
#fix manualy
tmpdf$emailaddress[tmp][1]<-"s.yi@ssw.rutgers.edu"
tmpdf$emailaddress[tmp][2]<-"margywaller@gmail.com"

#all these are not email addresses
tmp<-str_detect(
  tmpdf$emailaddress,
  "@"
) & str_detect(
  tmpdf$emailaddress,
  "\\.[a-z]{1,3}$"
)
tmpdf$emailaddress[!tmp]
tmpdf<-tmpdf[tmp,]

###########################################
###########################################

emails<-unique(tmpdf$emailaddress)
emailsdf<-lapply(emails,function(email) {
  
  #email<-emails[1]
  thisrow<-tmpdf$emailaddress==email
  thisdf<-tmpdf[thisrow,]
  
  #only want one firstname/lastname
  lastname<-thisdf$lastname[order(thisdf$lastname)[1]]
  firstname<-thisdf$firstname[order(thisdf$firstname)][1]
  
  #paste together affil 
  affiliation<-paste0(
    thisdf$affiliation,
    collapse=" / "
  )
  #discipline
  discipline<-paste0(
    thisdf$discipline,
    collapse=" / "
  )
  
  #return
  data.frame(
    email,
    firstname,
    lastname,
    affiliation,
    discipline,
    stringsAsFactors=F
  )
  
}) %>% rbind.fill

###########################################
###########################################

#output 
setwd(datadir)
write.csv(
  emailsdf,
  "emailsdf.csv",
  row.names=F
)