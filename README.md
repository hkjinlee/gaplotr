# GAplotR

## Overview
GAplotR is a simple tool which generates chart image files from Google Analytics data. Its purpose is:

- Query Google Analytics data by its API (using [googleAnalyticsR](https://github.com/MarkEdmondson1234/googleAnalyticsR) package)
- Generate chart image (using [ggplot2](https://github.com/tidyverse/ggplot2) package)

## Key Features

- Data from Google Analytics
  - Can do OAuth itself, or get credentials(access tokens and refresh tokens) from outside
  - Can cache the latest data to reduce the response time and manage API quota
- Chart generation
  - Supports Line chart, Bar chart, and Table
  - For Line and Bar chart, can display multiple metrics at the same time.
  - Output format: PNG

## Installation
GAplotR is still under development. You can install this package by using [devtools](https://github.com/hadley/devtools/)
```{r}
library(devtools)
install_github('hkjinlee/gaplotr')
```

### GA configuration
You need to start from adding new [views of Google Analytics](https://support.google.com/analytics/answer/2649553?hl=en).

### Configuration file format: JSON
Create `ga` directory under your working directory, and put a per-site configuration file there, which looks like this. Change `view_id` to one of your own.
```{json}
{
  "site_name": "some_project"
  "view_id": "ga:XXXXXXX"
}
```
### Multiple configuration files
You can add as many views at the same time. Configuration files can have any name you like, once it has '.json' extension.
```{sh}
hkjinlee-mac:ga hkjinlee$ ls
onestore_app.json    onestore_web.json
```

## Usage

### Authentication on the first execution
- gaplotr caches the credentials after the first authentication is successfully finished. The credentials will be written in the JSON file per view.

```{r}
library(gaplotr)

gaplotr <- gaplotr::gaplotr()
```

### Customization
You can create your own configuration file for customization. For configuration file format, please refer to [default config file](https://github.com/hkjinlee/gaplotr/blob/master/inst/etc/config.json). These default values are overridden by custom configuration, if any.

```{r}
library(gaplotr)

gaplotr <- gaplotr::gaplotr('path/to/configfile.json')
```

### Execution
The example below will generate three charts, of which output directory is `figure` under `cwd`.

```{r}
library(gaplotr)

gaplotr <- gaplotr::gaplotr()

getChartParams <- function(type) {
  list(
    type = type,
    title = paste(type, '차트'),
    filename = paste0(type, 'chart.png')
  )
}

ga_params <- list(
  site_name = 'onestore_app',
  view_id = 'XXXXXXXX'
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
```