#!/usr/bin/env Rscript

source('gaplotr.R')

gaplotr <- GAplotR(file.path('etc', 'config.json'))

site.id <- 'onestore_app'
json <- '{
  "dimensions": "ga:date",
  "metrics": ["ga:users", "ga:newUsers"],
  "start-date": "7daysAgo",
  "end-date": "today"
}'
chart.type <- 'line'
chart.title <- '차트'

gaplotr$generateChart(site.id, chart.type, json, chart.title, 'example.png')
