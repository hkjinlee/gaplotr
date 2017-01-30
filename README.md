# GAplotR

## Overview
GAplotR is a simple tool which generates chart image files from Google Analytics data. Its purpose is:

- Query Google Analytics data by its API (using [rga](https://github.com/skardhamar/rga) package)
- Generate chart image (using [ggplot2](https://github.com/tidyverse/ggplot2) package)

## Key Features

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

```{r}
library(gaplotr)

gaplotr <- gaplotr::gaplotr('path/to/configfile.json')
```

```
Mon Jan 30 16:29:40 2017 OAuth started: view.name = onestore_app 
Browse URL: https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/analytics.readonly&state=%2Fprofile&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=63451810083-rnehcshmkhvs0uabbdosm39mi96dentr.apps.googleusercontent.com&approval_prompt=force&access_type=offline 
Please enter code here: 
```

### Customization
You can create your own configuration file for customization. For configuration file format, please refer to [default config file](https://github.com/hkjinlee/gaplotr/blob/master/inst/etc/config.json). These default values are overridden by custom configuration, if any.

```{r}
library(gaplotr)

gaplotr <- gaplotr::gaplotr('path/to/configfile.json')
```

### Execution
Default chart output directory is `figure` under working directory.

```{r}
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
```