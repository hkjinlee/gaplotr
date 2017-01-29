#!/usr/bin/env Rscript

library(httr)
library(gaplotr)

gaplotr <- gaplotr::gaplotr()

site.id <- 'onestore_app'
params <- list(
  dimensions   = "ga:date",
  metrics      = c("ga:users", "ga:newUsers"),
  `start-date` = "7daysAgo",
  `end-date`   = "today"
)
chart.title <- '차트'

gaplotr$generateChart(site.id, 'line', params, chart.title, 'linechart.png')
gaplotr$generateChart(site.id, 'bar', params, chart.title, 'barchart.png')
gaplotr$generateChart(site.id, 'table', params, chart.title, 'table.png')
