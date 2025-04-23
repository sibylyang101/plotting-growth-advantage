library(tidyverse)
library(jsonlite)
library(cowplot)
library(lubridate)
library(ggsci)
library(patchwork)
library(RColorBrewer)
library(ggthemes)
theme_set(theme_cowplot())

adv = read_csv('results/adv.csv') %>% filter(variant != 'MV.1')
adv$variant = factor(adv$variant,levels = c('XEC','LF.7', 'LF.7.2.1','MC.10.1','NP.1', 'LP.8','LP.8.1'))

draw_point = function(var_base){
  adv %>% filter(variant_base==var_base) %>% 
    ggplot(aes(x = variant,y = adv_mle,color=variant)) + 
    geom_point(size=1.5) + 
    geom_errorbar(aes(ymin = adv_low, ymax = adv_high), width = 0.3) + 
    scale_color_locuszoom() + 
    # scale_color_manual(values=colors) + 
    # theme_classic() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    guides(color = "none")+
    labs(x = '',y = str_glue('growth advantage over {var_base}*'))
}


p1 = draw_point(var_base='KP.3') + scale_y_continuous(limits=c(0,0.7)) #,expand=expansion()
p2 = draw_point(var_base='KP.3.1.1') + scale_y_continuous(limits=c(0,0.7))
p3 = draw_point(var_base='XEC') # + scale_y_continuous(expand=expansion())
p1 + p2 + p3

p  = draw_point(var_base='KP.3.1.1') + scale_y_continuous(limits=c(0,0.7),expand=expansion())
pdf('results/adv_KP311.pdf',height=4.5,width=3)
p
dev.off()

