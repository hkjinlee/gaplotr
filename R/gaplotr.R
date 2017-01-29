#'
#' @title gaplotr
#' @description Generates PNG charts from Google Analytics API
#' @details etc

#' @import jsonlite
#' @import rga
#' @importFrom httr POST

#'
#' @export
gaplotr <- function(config.json=file.path('etc', 'config.json')) {
  this <- new.env()

  # 설정 읽어들임
  config <- jsonlite::fromJSON(config.json)

  # 주요 유틸리티들 초기화
  cache <- cache.new(config$cache)
  
  # 디멘전과 메트릭에 대한 번역테이블 초기화
  dict <- dict.new()
  dict$add('dimension', file.path('etc', 'dimension_name.csv'))
  dict$add('metric', file.path('etc', 'metric_name.csv'))
  
  # ggplot용 유틸리티 초기화
  ggplot <- ggplot.new(config$ggplot, dict)
  
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
    site <- jsonlite::fromJSON(file.path(config$sites$dir, site.file))
    rga.file <- file.path(config$sites$dir, paste0(site.id, '.rga'))
    
    # OAuth 인증
    rga::rga.open(instance=get_ga_name(site.id), 
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

  # 차트 이미지를 생성
  # - type: { 'bar', 'line' }
  this$generateChart <- function(site.id, type, json, title, filename) {
    v('generateChart(): site.id=%s, type=%s, json=%s', site.id, type, json)

    # 차트용 데이터 fetch. 유효한 캐쉬가 없으면 getData()를 호출하여 직접 가져옴
    args <- jsonlite::fromJSON(json)
    data <- cache$get(site.id, args, getData)
    
    # dimension과 metric 추출 ('ga:visits' -> 'visit'로 변경)
    dimensions <- gsub('^ga:', '', args$dimensions)
    metrics <- gsub('^ga:', '', args$metrics)

    # 차트 render
    gg <- ggplot$render(data, type, dimensions, metrics, title)

    # 차트 저장
    file.path <- ggplot$save(gg, filename)
    
    return(file.path)
  }
  
  return(this)
}