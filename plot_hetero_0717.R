# 
 library(ggplot2)
# library(plyr)
# library(reshape)
# library(foreign)
# library(grid)
# library(gridExtra)
# library(RColorBrewer)
# library(scales)
# library(ggExtra)
# library(fmsb)
# library(lattice)
# library(ggthemes)
# library(ggmap)
# library(fields)
# library(maptools)
# library(sp)
# library(rgdal)
 library(xlsx)
# library(lpSolve)
# library(readstata13)
# library(tidyverse)
# library(quantreg)
# library(ggpubr)
# library(rpart)

rm(list=ls())
cat("\014")



#setwd("")



#data<-read.xlsx2("hetero_coefficients.xlsx", "Sheet1")

data<-read.xlsx2("hetero_coefficients_0719.xlsx", "Sheet1")

data<-reshape(data, 
              varying=c("upper", "lower"),
              v.names="value",
              timevar="boundary",
              times=c("upper", "lower"),
              direction="long")

data$mean<-as.numeric(data$mean)
data$value<-as.numeric(data$value)


data$group<-factor(data$group, 
           levels=c("All","Low income","Middle income","High income", "Low intensity", "Middle intensity","High intensity","Low PVA","Middle PVA","High PVA"), order=T) 

data$type<-factor(data$type, 
                                levels=c("Occurrence","Length"), order=F) 
        
data<- data[with(data, order(type, group)), ]



residential<-ggplot()
residential<-residential+geom_point(data =data,
                                  aes(x =group,y =mean, color=type), position =position_dodge(width = 0.5), size=7)
residential<-residential+geom_line(data =data,
                                  aes(x =group,y =value, color=type, group=interaction(group,type)), position = position_dodge(width = 0.5), linewidth=2.5)
residential<-residential+theme_bw()+theme(legend.position="bottom",
                                        legend.direction = "horizontal",
                                        panel.grid.major = element_blank(),
                                        panel.grid.minor = element_blank(),
                                        strip.background = element_blank(),
                                        text = element_text(size=15))+ylab("Residential outage") + xlab("Socio-demographic groups")
residential<-residential+geom_hline(yintercept=0, linetype="dashed", linewidth=1)
 
residential+scale_y_discrete(breaks=seq(-0.1,0.2,by=0.05))
residential

ggsave("figure 2_0719.pdf", residential, width = 16.2, height=10, units="in", dpi=900)




