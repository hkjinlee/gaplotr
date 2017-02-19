#!/usr/bin/env Rscript

library(gaplotr)

gaplotr <- gaplotr::gaplotr()

getChartParams <- function(type) {
  list(
    type = type,
    title = paste(type, '차트'),
    filename = paste0(type, 'chart.png'),
    lang = 'ja'
  )
}
ga_params <- list(
  site_name = 'onestore_app',
  view_id = '103842051'
)
query <- list(
  dimensions   = "ga:date",
  metrics      = c("ga:users", "ga:newUsers"),
  `start-date` = "7daysAgo",
  `end-date`   = "today"
)

gaplotr$generateChart(ga_params, getChartParams('line'), query)
gaplotr$generateChart(ga_params, getChartParams('bar'), query)
gaplotr$generateChart(ga_params, getChartParams('table'), query)
