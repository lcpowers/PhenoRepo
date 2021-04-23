rm(list=ls())
library(reshape2)

forecast_startdate <- "2021-03-01"

sarima <- read_csv("R/score_dfs/SArima_4cast_2021-04-19.csv") %>% 
  filter(time>=forecast_startdate) %>% 
  filter(siteID=="GRSM")
sarima_scores <- neon4cast::score(sarima,theme=c("phenology"))

EFInullmodel <- read_csv("R/score_dfs/nullmodel_4cast_2021-04-19.csv") %>% 
  filter(time>=forecast_startdate) %>% 
  filter(siteID=="GRSM")
efi_scores <- neon4cast::score(EFInullmodel,theme=c("phenology"))

caseymod <- read_csv("data/model/model_data.csv") %>% 
  select(-'X1',-day,-gcc_90) %>% 
  # filter(time>=forecast_startdate) %>% 
  mutate(siteID="GRSM")

targets <- read_csv("data/model/model_data.csv") %>% select(time,targets=gcc_90)

x=1:nrow(caseymod)
plot(x,caseymod$model_results,type="l")
# Add some observation error
# Suggest logit scale with Normal distribution for error

# This is too large based on scores
sd_obs <- sd(caseymod$model_results)

# This is too small. var() is also too small
# se_obs <- sd(caseymod$gcc_90)/sqrt(length(caseymod$gcc_90))

simdat <- rnorm(length(caseymod$model_results),log(caseymod$model_results/(1-caseymod$model_results)), sd_obs)
simdat <- exp(simdat) / (1 + exp(simdat))
plot(x,caseymod$model_results,type="l",ylim=c(0,1))
points(x,simdat/50,col="green")

##### THIS SD ####
caseymod$gcc_sd <- simdat


# plot(x,caseymod$gcc_90,type="l",ylim=c(0,0.5))
# points(x,caseymod$gcc_sd,col="green")


# Check measurement error in plot
ggplot(caseymod,aes(x=time))+
  geom_line(aes(y=gcc_90))+
  geom_point(aes(y=gcc_sd))+
  theme_classic()

casey_scoredf <- caseymod %>% 
  melt(id.vars = c("time","siteID"),
       variable.name = "statistic",
       value.name = "gcc_90") %>% 
  mutate(forecast=1,
         obs_flag=2,
         data_assimilation=0) %>% 
  select(time,siteID,obs_flag,forecast,data_assimilation,statistic,gcc_90) %>% 
  filter(time>=forecast_startdate)
casey_scoredf$statistic <- ifelse(casey_scoredf$statistic=="model_results","mean","sd")
casey_scoredf$statistic <- as.character(casey_scoredf$statistic)

# write_csv(casey_scoredf,paste0("R/score_dfs/casey_4cast_",Sys.Date(),".csv"))

springtheory_scores <- neon4cast::score(casey_scoredf,theme = c("phenology"))

all_scores <- merge(sarima_scores,efi_scores,by = c('time','siteID','target'), suffixes = c(".sar",".efi")) %>% 
  merge(.,springtheory_scores,by = c('time','siteID','target')) 

colnames(all_scores)[6]<-"score.ST"
score_plot <- melt(all_scores,id.vars = c('time','siteID','target'),variable.name = "source",value.name = 'score')

ggplot(score_plot, aes(x=time,y=score))+
  geom_line(aes(color=source))+
  # scale_y_continuous(limits=c(0,0.02))+
  scale_x_date(breaks="1 week")+
  theme_classic()

sarima <- sarima %>% 
  filter(statistic=="mean") %>% 
  select(time,siteID,gcc_90)

st <- casey_scoredf %>% 
  filter(statistic=="mean") %>% 
  select(time,siteID,gcc_90)

efi <- EFInullmodel %>% 
  group_by(time,siteID) %>% 
  summarise(gcc_90=mean(gcc_90,na.rm = T))

target_plot <- merge(sarima,st,by=c('time',"siteID"), suffixes = c(".sar",".st")) %>% 
  merge(.,efi,by=c('time',"siteID")) %>% 
  merge(.,targets,by=c('time')) %>% 
  melt(id.vars=c("time","siteID"),variable.name="source",value.name = "gcc_90")

target_plot$source <- as.character(target_plot$source)
target_plot$source[target_plot$source=='gcc_90']<-"gcc_90.efi"

ggplot(target_plot,aes(x=time,y=gcc_90))+
  geom_line(aes(color=source))+
  geom_point(aes(color=source,shape=source),size=2)+
  scale_color_manual(values = c("grey70","steelblue","springgreen3","indianred"),labels=c("EFI","Sarima","Us","Targets"))+
  scale_shape_discrete(labels=c("EFI","Sarima","Us","Targets"))+
  theme_classic(base_size = 18)+
  scale_x_date(breaks="1 week")+
  labs(y="GCC 90 Value")
  
