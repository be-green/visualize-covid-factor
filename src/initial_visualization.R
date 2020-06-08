library(data.table)
library(stringr)
library(ggplot2)
library(highcharter)
library(quanteda)
library(highcharter)
library(htmlwidgets)

hcGopts <- getOption("highcharter.global")
hcGopts$useUTC = T
hcGopts$timezone = "America/New_York"
hcGopts$timezoneOffset = 5 * 60
options(highcharter.global = hcGopts)

covid_factor <- fread("data/processed/intraday-covid-factor.csv")
xts_factor <- covid_factor[,.(datetime = as.POSIXct(tz = "America/New_York",
  paste(as.Date(datadate, format = "%d%b%Y"), 
        str_replace_all(itime_m, "01jan1960 ","")
        )
                                      ),
                index_level = (index_level_iday - 1) * 100
                )] %>% 
  as.xts.data.table()


covid_news <- fread("data/raw/news-data/kaggle/news.csv", header = T)

test_cases <- head(covid_news$publish_date)


x <- c("Cumulative Return: ", "Date/Time: ")
y <- c("{point.y:.2f}%", "{point.x:%b %e %I:%M %p}")
tltip <- tooltip_table(x, y)

datetimeformats = 
"{
    millisecond: '%H:%M:%S.%L',
    second: '%H:%M:%S',
    minute: '%H:%M',
    hour: '%H:%M',
    day: '%e. %b',
    week: '%e. %b',
    month: '%b \'%y',
    year: '%Y'
}"

mit_theme <- hc_theme(
  colors = c("#a31f34", 
             "#041d40",
             "#00698e",
             "006b67"),
  chart = list(
    background_color = "#c9c8c7",
    plotBorderColor = "",
    style = list(
      fontFamily = c("Futura LT W01 Bold", "sans-serif"),
      color = "#545759",
      fontWeight = 600
    )
  )
)


hc <- highchart(type = "stock") %>% 
  hc_add_series(xts_factor) %>%
  hc_title(text = "Cumulative Returns to Long-Short COVID Factor<br>Since Jan 2") %>% 
  hc_tooltip(useHTML = TRUE, pointFormat = tltip) %>% 
  hc_xAxis(dateTimeLabelFormats = list(day = "%b %e"),
           time = list(timezone = 'America/New_York'),
           gridLineWidth = 1,
           gridLineColor = '#e9e9e9') %>% 
 hc_add_theme(mit_theme)

wd <- getwd()

setwd("viz/factor-returns/")
saveWidget(hc, file="returns.html")

setwd(wd)
