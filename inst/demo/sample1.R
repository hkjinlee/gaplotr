#!/usr/bin/env Rscript

library(gaplotr)

gaplotr <- gaplotr::gaplotr()

site.id <- 'onestore_app'
params <- list(
  dimensions   = "ga:date",
  metrics      = c("ga:users", "ga:newUsers"),
  `start-date` = "7daysAgo",
  `end-date`   = "today"
)
chart.type <- 'line'
chart.title <- '차트'

gaplotr$generateChart(site.id, chart.type, params, chart.title, 'example.png')

