#!/usr/bin/env Rscript

library(gaplotr)

gaplotr <- gaplotr::gaplotr()

view.name <- 'onestore_app'
params <- list(
  dimensions   = "ga:date",
  metrics      = c("ga:users", "ga:newUsers"),
  `start-date` = "7daysAgo",
  `end-date`   = "today"
)
chart.title <- '차트'

gaplotr$generateChart(view.name, 'line', params, chart.title, 'linechart.png')
gaplotr$generateChart(view.name, 'bar', params, chart.title, 'barchart.png')
gaplotr$generateChart(view.name, 'table', params, chart.title, 'table.png')
