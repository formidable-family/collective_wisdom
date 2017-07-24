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

#########################################################
#########################################################

#plotting prelims
require(ggplot2)
require(ggthemes)
require(extrafont)
require(RColorBrewer)
#load fonts
loadfonts() #register w/ pdf
loadfonts(device = "win") #register w/ windows
fonts()
#get ghostscript, for tex output
Sys.setenv(
  R_GSCMD = "C:/Program Files/gs/gs9.20/bin/gswin64c.exe"
)
#initialize graphlist
gs.list<-list()

#########################################################
#########################################################

#load directory
setwd(homedir); dir()
outputdir<-file.path(
  homedir,
  "output"
)
setwd(outputdir); dir()
varsdf<-read.csv(
  'ffvars_scored.csv',
  stringsAsFactors=F
)

#########################################################
#########################################################

# ###make plot of avg
# head(varsdf)
# 
# tmp<-!is.na(varsdf$experts) & !is.na(varsdf$mturkers)
# tmp<-tmp & !varsdf$outcome%in%c(
#   "layoff",
#   "job_training"
# )
# tmpdf<-varsdf[tmp,]
# 
# #collapse
# tmplist<-list(
#   tmpdf$idea,
#   tmpdf$outcome
# )
# plotdf<-by(tmpdf,tmplist,function(df) {
#   #tmp<-tmpdf$idea==unique(tmpdf$idea)[2] &
#   #  tmpdf$outcome=="eviction"
#   #df<-tmpdf[tmp,]
#   data.frame(
#     idea=unique(df$idea),
#     outcome=unique(df$outcome),
#     experts=mean(df$experts,na.rm=T),
#     mturkers=mean(df$mturkers,na.tm=T),
#     stringsAsFactors=F
#   )
# }) %>% rbind.fill
# 
# #loop through each outcome
# outcomes<-plotdf$outcome %>% 
#   unique
# 
# gs<-lapply(outcomes,function(outcome) {
#   #outcome<-"eviction"
#   df<-plotdf[plotdf$outcome==outcome,]
#   tmplevels<-df$idea[order(df$experts)]
#   df$idea<-factor(
#     df$idea,
#     levels=tmplevels,
#     labels=tmplevels
#   )
#   
#   #this is for the points
#   newdf<-gather(
#     df,
#     type,
#     score,
#     experts:mturkers
#   )
#   
#   #this is the graph
#   ggplot(
#     df,
#     aes(
#       x=idea
#     )
#   ) + 
#     geom_errorbar(
#       mapping=aes(
#         ymax=experts,
#         ymin=mturkers
#       ),
#       width=0
#     ) +
#     geom_point(
#       data=newdf,
#       mapping=aes(
#         x=idea,
#         y=score,
#         color=type
#       )
#     ) + 
#     scale_color_discrete(
#       name=""
#     ) +
#     geom_hline(
#       yintercept=50,
#       alpha=0.2,
#       linetype='dashed'
#     ) +
#     xlab("") +
#     ylab("\n Score") +
#     labs(title=outcome) +
#     coord_flip() + 
#     theme_bw(
#       base_family="CM Roman",
#       base_size=14
#     ) 
#   
# })
# names(gs)<-outcomes
# 
# 
# tmpseq.i<-seq_along(gs)
# for(i in tmpseq.i) {
#   #i<-1
#   g<-gs[i][[1]]
#   gname<-names(gs)[i]
#   filename<-paste0(gname,".pdf")
#   gs.list[[gname]]<-list(
#     graph=g,
#     filename=filename,
#     width=8,
#     height=6
#   )
# }

###########################################
###########################################

roworder<-order(
  varsdf$outcome,
  -varsdf$mturkers
)
colorder<-c(
  "outcome","idea","mturkers","user.submitted"
)
tmpdf<-varsdf[roworder,colorder]
tmpdf<-unique(tmpdf)

plotdf<-by(tmpdf,tmpdf$outcome,function(df) {
  roworder<-order(
    -df$mturkers
  )
  df<-df[roworder,]
  df$rank<-1:nrow(df)
  df
}) %>% rbind.fill
head(plotdf)

plotdf$user.submitted<-factor(
  plotdf$user.submitted,
  levels=c(T,F),
  labels=c("user submitted","seeded")
)


g.tmp<-ggplot(
  data=plotdf,
  aes(
    x=rank,
    y=mturkers,
    color=user.submitted
  )
) + geom_point(
  size=1
) +
  facet_wrap(~ outcome) +
  geom_hline(
    size=0.5,
    yintercept=50,
    linetype='dashed',
    alpha-0.2
  ) +
  scale_color_discrete(
    name=""
  ) +
  xlab("\nrank") +
  ylab("") +
  theme_bw(
    base_family="CM Roman",
    base_size=14
  ) 
g.tmp

gs.list[["fig_dist"]]<-list(
  graph=g.tmp,
  filename="fig_dist.pdf",
  width=7,
  height=5
)

g.tmp<-ggplot(
  data=plotdf,
  aes(
    x=rank,
    y=mturkers,
    fill=user.submitted,
    color=user.submitted
  )
) + geom_bar(
  stat='identity'
) +
  facet_wrap(~ outcome) +
  geom_hline(
    yintercept=50,
    linetype='dashed',
    alpha-0.2
  ) +
  xlab("\nrank") +
  ylab("") +
  theme_bw(
    base_family="CM Roman",
    base_size=14
  ) 
g.tmp

gs.list[["fig_distbar"]]<-list(
  graph=g.tmp,
  filename="fig_distbar.pdf",
  width=7,
  height=5
)



###########################################
###########################################

#OUTPUT
#output graphlist
setwd(outputdir)
this.sequence<-seq_along(gs.list)
for(i in this.sequence) {
  Sys.sleep(1)
  print(
    paste0(
      "saving ",i," of ",length(this.sequence)
    )
  )
  thiselement<-gs.list[[i]]
  ggsave(
    filename="tmp.pdf",
    plot=thiselement$graph,
    width=thiselement$width,
    height=thiselement$height
  )
  #embed font
  embed_fonts(
    file="tmp.pdf",
    outfile=thiselement$filename
  )
  file.remove(
    "tmp.pdf"
  )
}
