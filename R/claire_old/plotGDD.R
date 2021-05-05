### GDD plots
ggplot(subset(all_df,siteID=="GRSM"&year==2019),aes(x=date,y=daily_mean))+
  geom_point(color="springgreen4",size=2,alpha=0.75)+
  geom_hline(yintercept = base_temp,color='grey70',linetype=2)+
  scale_x_date(date_breaks='3 months',date_labels ="%b")+
  theme_classic(base_size = 14)+
  labs(x="2019",y=expression('24-hr mean temperature ('*degree*C*')'))
ggsave("PrezFigures/GRSM2019temps.png",dpi=400,height=3,width=4)

ggplot(subset(all_df,siteID=="GRSM"&year==2019),aes(x=date,y=GDDdaily))+
  geom_point(color="springgreen4",size=2,alpha=0.75)+
  #geom_hline(yintercept = base_temp,color='grey70',linetype=2)+
  scale_x_date(date_breaks='3 months',date_labels ="%b")+
  theme_classic(base_size = 14)+
  labs(x="2019",y="Daily growing degree units")
ggsave("PrezFigures/GRSM2019GDDdaily.png",dpi=400,height=3,width=4)

ggplot(subset(all_df,siteID=="GRSM"&year==2019),aes(x=date,y=GDDtotal))+
  geom_line(color="springgreen4",size=1)+
  #geom_hline(yintercept = base_temp,color='grey70',linetype=2)+
  scale_x_date(date_breaks='3 months',date_labels ="%b")+
  theme_classic(base_size = 14)+
  labs(x="2019",y="Total growing degree units")
ggsave("PrezFigures/GRSM2019GDDtotal.png",dpi=400,height=3,width=4)

ggplot(subset(all_df,siteID=="GRSM"),aes(x=date,y=GDDtotal))+
  geom_line(color="springgreen4",size=1)+
  #geom_hline(yintercept = base_temp,color='grey70',linetype=2)+
  scale_x_date(date_breaks='years',date_labels ="%b %y")+
  theme_classic(base_size = 14)+
  labs(x="",y="Total growing degree units")
ggsave("PrezFigures/GRSMGDDtotal.png",dpi=400,height=3,width=4)