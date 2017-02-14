#'
#' @title gaplotr
#' @description Generates PNG charts from Google Analytics API
#' @details etc

#' @import jsonlite
#' @importFrom httr oauth_app oauth_endpoints Token2.0 
#' @import googleAuthR
#' @import googleAnalyticsR

#'
#' @export
gaplotr <- function(config.json = NULL) {
  this <- new.env()

  # 기본설정 읽어들인 뒤 추가설정 overwrite
  config.default.json <- system.file(file.path('etc', 'config.json'), package = 'gaplotr')
  config <- jsonlite::read_json(config.default.json, simplifyVector = T)
  if (!is.null(config.json))
    config <- modifyList(config, jsonlite::read_json(config.json, simplifyVector = T))

  # 로그레벨 설정
  loglevel(config$loglevel)
  
  # 주요 유틸리티들 초기화
  info('START Initialization of cache, dict, plotter...')
  cache <- cache.new(config$cache)
  
  # 디멘전과 메트릭에 대한 번역테이블 초기화
  dict <- dict.new()
  dict$add('dimension')
  dict$add('metric')
  
  # ggplot, grid용 유틸리티 초기화
  plotter <- plotter.new(config$plotter, dict)

  info('END Initialization of cache, dict, plotter...')

  # OAuth 인증용 기본객체 생성
  app <- httr::oauth_app('google', key = config$ga$client_id, secret = config$ga$client_secret)
  endpoint <- httr::oauth_endpoints('google')
  
  # 차트 이미지를 생성.
  # plot을 그린 뒤 저장하는 것이 아니고, 저장위치(파일)를 정해두고 그쪽에 그리는 것임.
  # - type: { 'bar', 'line', 'table' }
  this$generateChart <- function(ga_params = list(site_name = NULL, view_id = NULL, access_token = NULL),
                                 chart_params = list(title = NULL, type = NULL, filename = NULL),
                                 query_params) {
 #   debug('generateChart(): ga_params=%s, chart_params=%s, query_params=%s', ga_params, chart_params, query_params)

    # 차트용 데이터 fetch. 유효한 캐쉬가 없으면 getData()를 호출하여 직접 가져옴
debug('before cache$get')
    data <- cache$get(ga_params, query_params, getData)
debug('afer cache$get')
    
    # dimension과 metric 추출 ('ga:visits' -> 'visit'로 변경)
    dimensions <- gsub('^ga:', '', query_params$dimensions)
    metrics <- gsub('^ga:', '', query_params$metrics)

    # 차트 renderer 지정
    renderer.func <- function() {
      if (chart_params$type != 'table') {
        plotter$chartRenderer(data, chart_params$type, dimensions, metrics, chart_params$title)
      } else {
        plotter$tableRenderer(data, dimensions, metrics, chart_params$title)
      }
    }

    # 차트 저장
    file.path <- plotter$save(renderer.func, chart_params$filename)
    
    return(file.path)
  }
  
  # GA로부터 데이터 조회
  getData <- function(ga_params, query_params) {
    #debug('getData(): view_id = %s, query_params = %s', ga_params$view_id, query_params)
    
    # accessToken 정보 설정
    token <- httr::Token2.0$new(app = app, endpoint = endpoint, cache_path = F, 
                          credentials = list(access_token = ga_params$access_token),
                          params = list(as_header = T)
    )
    googleAuthR::gar_auth(token = token)
    
    # 데이터 조회
    data <- googleAnalyticsR::google_analytics_4(ga_params$view_id,
                       date_range = c(query_params[['start-date']], query_params[['end-date']]), 
                       dimensions = unlist(query_params$dimensions), 
                       metrics = unlist(query_params$metrics)
    )

    debug('getData(): data = %s', data)
    data
  }

  return(this)
}
