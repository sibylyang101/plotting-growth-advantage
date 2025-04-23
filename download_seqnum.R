library(tidyverse)
library(Biostrings)
library(jsonlite)
library(cowplot)
library(lubridate)
library(ggsci)
library(patchwork)
library(RColorBrewer)
library(ggthemes)
library(scales)

# source('/Users/sibyl/Desktop/XieLab/2022/utils.R')
theme_set(theme_cowplot())

#######################
jsonfile2DF = function(path,keep_country = F){
  Jfile = read_json(path)
  if(keep_country == F){
    DF = lapply(Jfile$data,function(x){
      data.frame(date = x$date,
                 count = x$count)}) %>% 
      bind_rows %>% arrange(date)
    return(DF)
  }
  if(keep_country == T){
    DF = lapply(Jfile$data,function(x){
      data.frame(date = x$date,
                 country = x$country,
                 count = x$count)}) %>% 
      bind_rows %>% arrange(date)
    return(DF)
  }
}

#######################
#### from cov-spectrum
#######################
setwd('/Users/sibyl/Desktop/XieLab/05_model/GA_plot/plotting_growth_advantage/results')
date_from <- '2024-01-01'
# save_date = Sys.Date()
save_date = '2024-12-17'

# country='China'
# aamut='S:456L'
strains = c('XEC','KP.3.1.1', # JN.1.11.1.3.1.1
            'KP.3',
            'LP.8.1', 'LP.8', # JN.1.11.1.1.1.3.8
            'MC.10.1', # JN.1.11.1.3.1.1.10.1
            'NP.1', # JN.1.11.1.3.3.2.1
            'LF.7', 'LF.7.2.1',  # JN.1.16.1.7
            'MV.1'  # JN.1.49.1.1.1.1.1
            )

for(strain_i in strains){
  query = str_c('https://lapis.cov-spectrum.org/gisaid/v2/sample/aggregated?', #v2
                'dateFrom=',date_from,
                '&nextcladePangoLineage=',strain_i,'*',
                # '&aminoAcidMutations=',aamut,
                # '&country=',country,
                '&host=Human&accessKey=9Cb3CqmrFnVjO3XCxQLO6gUnKPd&fields=date' # %2Ccountry
                # '&dataVersion=',data_version
  )
  print(query)
  download.file(query,paste0(strain_i,
                             # '+',aamut %>% str_remove_all('S:') %>% str_replace_all(',','+'),
                             '_',save_date,'.json'), method='wget')
}

### all
query = str_c('https://lapis.cov-spectrum.org/gisaid/v2/sample/aggregated?', #v2
              'dateFrom=',date_from,
              # '&country=',country,
              '&host=Human&accessKey=9Cb3CqmrFnVjO3XCxQLO6gUnKPd&fields=date' # %2Ccountry
              # '&dataVersion=',data_version
)
download.file(query,paste0('all','_',save_date,'.json'), method='wget')

############
Ldata = lapply(c('all',strains),function(strain_i){
  jsonfile2DF(str_glue('{strain_i}_{save_date}.json')) %>% 
    dplyr::rename(!!str_c(strain_i) := !!sym('count'))})

data = purrr::reduce(Ldata,full_join) %>% 
  mutate_all(~replace(., is.na(.), 0)) %>%  
  mutate(date = as.Date(date))
data %>% write_csv('sequence_combine.csv')
