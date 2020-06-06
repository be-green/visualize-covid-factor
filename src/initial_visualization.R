library(data.table)
library(stringr)
library(ggplot2)
library(highcharter)
library(quanteda)

covid_factor <- fread("data/processed/intraday-covid-factor.csv")
tidyr::separate(covid_factor, datadate, into = c("date", "origin"))
xts_factor <- covid_factor[,.(datetime = as.POSIXct(paste(as.Date(datadate, format = "%d%b%Y"), 
                                            str_replace_all(itime_m, "01jan1960 ","")
                                            )
                                      ),
                index_level = index_level_iday
                )] %>% 
  as.xts.data.table()


covid_news <- fread("data/raw/news-data/kaggle/news.csv", header = T)

highchart(type = "stock") %>% 
  # hc_chart(type = "line") %>% 
  hc_add_series(xts_factor) %>% 
  hc_add

