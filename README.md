# GAplotR

## Overview
GAplotR is a simple tool which generates chart image files from Google Analytics data. Its purpose is:

- Query Google Analytics data by its API (using [rga](https://github.com/skardhamar/rga) package)
- Generate chart image (using [ggplot2](https://github.com/tidyverse/ggplot2) package)

## Installation
GAplotR is still under development. You can install this package by using [devtools](https://github.com/hadley/devtools/)
```{r}
library(devtools)
install_github('hkjinlee/gaplotr)
```

## Sites configuration
You need to start from adding new site configuration. Each site corresponds to a specific [view of Google Analytics](https://support.google.com/analytics/answer/2649553?hl=en). You can add multiple sites by providing id of those views.

### Configuration file format: JSON
Create `site` directory under your working directory, and put a per-site configuration file there, which looks like this. Change `view_id` to one of your own.
```{json}
{
  'view_id': 'ga:XXXXXXX'
}
```
### Multiple configuration files
You can add as many sites at the same time. Configuration files can have any name you like, once it has '.json' extension.
```{sh}
hkjinlee-mac:sites hkjinlee$ ls
onestore_app.json    onestore_web.json
```

## Usage
```{r}
library(gaplotr)

# default configuration
gaplotr <- gaplotr::gaplotr()
```
