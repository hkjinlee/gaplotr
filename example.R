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

gaplotr$generateChart(site.id, json, '차트', 'example.png')
