#

library(ggplot2)
library(jsonlite)
library(rga)

source('dict.R')
source('cache.R')

GAplotR <- function(config.json=file.path('etc', 'config.json')) {
  this <- new.env()
  class(this) <- 'GAplotR'
  
  # 설정 읽어들임
  config <- read_json(config.json)

  # ggplot2에서 한글 깨지지 않도록 설정
  text <- theme_get()$text
  text$family <- config$ggplot$fontfamily
  theme_update(text=text)
  
  # 디버깅여부 설정
  this$debug <- config$debug

  # 디버깅용 로그메시지 출력용 함수
  v <- function(...) {
    if (this$debug) {
      cat(date(), class(this), sprintf(...), '\n', file=stderr())
    }
  }
  
  # 캐시 객체 초기화
  cache <- GAplotR.cache(config$cache)
  
  # 디멘전과 메트릭에 대한 번역테이블 초기화
  dimension.dict <- GAplotR.dict(file.path('etc', 'dimension_name.csv'))
  metric.dict <- GAplotR.dict(file.path('etc', 'metric_name.csv'))
  
  # rga 객체의 이름 조회
  get_ga_name <- function(site.id) {
    paste0('ga:', site.id)
  }
  
  # 사이트 정보 로딩 및 OAuth 실행
  this$sites <- list()
  Map(function(site.file) {
    v('loading site: %s', site.file)
    site.id <- gsub('\\.json$', '', site.file)

    v('OAuth started: site.id = %s', site.id)
    
    # sites의 view.id 정보 및 인증정보 저장파일
    site <- read_json(file.path(config$sites$dir, site.file))
    rga.file <- file.path(config$sites$dir, paste0(site.id, '.rga'))
    
    # OAuth 인증
    rga.open(instance=get_ga_name(site.id), 
             client.id=config$ga$client_id,
             client.secret=config$ga$client_secret,
             where=rga.file,
             envir=this)
    v('OAuth ended for %s', site.id)
    
    this$sites[[site.id]] <- site
  }, list.files(path=config$sites$dir, pattern='\\.json$')
  )
  v('sites loading finished. sites = %s', this$sites)

  # site.id를 이용해 view.id 조회
  get_view_id <- function(site.id) {
    v('get_view_id(): site.id = %s', site.id)
    view.id <- this$sites[[site.id]]$view_id
    v('get_view_id(): view.id = %s', view.id)
    view.id
  }
  
  # GA로부터 데이터 조회
  getData <- function(site.id, ...) {
    args <- list(...)[[1]]
    v('getData(): site.id = %s, args = %s', site.id, args)
    
    view.id <- get_view_id(site.id)
    v('view.id = %s', view.id)
    
    ga <- this[[get_ga_name(site.id)]]
    
    data <- ga$getData(ids=view.id,
                       start.date=args[['start-date']], 
                       end.date=args[['end-date']],
                       dimensions=paste(args$dimensions, collapse=','), 
                       metrics=paste(args$metrics, collapse=',')
    )
    v('getData(): data = %s', data)
    data
  }

  this$generateChart <- function(site.id, json, title, filename) {
    v('getData(): site.id = %s, json = %s', site.id, json)
    
    args <- fromJSON(json)
    data <- cache$get(site.id, args, getData)
    
    dimensions <- gsub('^ga:', '', args$dimensions)
    metrics <- gsub('^ga:', '', args$metrics)
    
    xlab <- dimension.dict$lookup(dimensions[1]) 
    ylab <- metric.dict$lookup(metrics[1])
    v('xlab = %s, ylab = %s', xlab, ylab)
    ggplot(data, aes_string(x=dimensions[1], y=metrics[1])) + 
      geom_line() + 
      geom_point() +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title)
    
    # 디렉토리 없으면 생성
    if (!dir.exists(config$ggplot$dir)) {
      dir.create(config$ggplot$dir)
    }
    filename <- file.path(config$ggplot$dir, filename)
    ggsave(filename, width=config$ggplot$width, height=config$ggplot$height, dpi=config$ggplot$dpi)
    
    v('Generated figure = %s', filename)
    filename
  }
  
  return(this)
}