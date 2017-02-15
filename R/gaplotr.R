#'
#' @title gaplotr
#' @description Generates PNG charts from Google Analytics API
#' @details etc

#' @import jsonlite
#' @importFrom httr oauth_app oauth_endpoints Token2.0 
#' @import googleAuthR
#' @import googleAnalyticsR

DEFAULT_AUTH_SCOPES <- 'https://www.googleapis.com/auth/analytics.readonly'

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
  
  # googleAuthR 기본설정
  options(googleAuthR.client_id = config$ga$client_id,
          googleAuthR.client_secret = config$ga$client_secret,
          googleAuthR.scopes.selected = DEFAULT_AUTH_SCOPES,
          googleAuthR.httr_oauth_cache = F)
  
  # 사이트 정보 로딩 및 OAuth 실행
  # 'onestore_app'이라는 account가 있을 경우, 
  # - this$views$onestore_app$view_id가 원스토어의 GA view id
  # - this$views$onestore_app$access_token
  # - this$views$onestore_app$refresh_token
  Map(function(view.json) {
    info('loading GA info from %s', view.json)

    # JSON파일로부터 환경 불러옴
    view <- jsonlite::fromJSON(view.json)
    
    # OAuth 인증
    if (is.null(view$credentials)) {
      info('OAuth cache not found. Requesting auth.')
      token <- gar_auth()
      view <- modifyList(view, list(credentials = token$credentials))
    }
    info('OAuth ended. credentials = %s', view$credentials)
    
    # 파일 저장
    write(jsonlite::toJSON(view, auto_unbox = T, pretty = T), file = view.json)
    
    view
  }, list.files(path = config$ga$dir, full.names = T, pattern = '\\.json$')
  )
  info('loading GA info finished. # of views = %d', length(this$views))  
  
  # 차트 이미지를 생성.
  # plot을 그린 뒤 저장하는 것이 아니고, 저장위치(파일)를 정해두고 그쪽에 그리는 것임.
  # - type: { 'bar', 'line', 'table' }
  this$generateChart <- function(ga_params = list(site_name = NULL, view_id = NULL, access_token = NULL),
                                 chart_params = list(title = NULL, type = NULL, filename = NULL),
                                 query_params) {
    debug('generateChart() started')

    # 차트용 데이터 fetch. 유효한 캐쉬가 없으면 getData()를 호출하여 직접 가져옴
    data <- cache$get(ga_params, query_params, getData)

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
    debug('getData(): view_id = %s', ga_params$view_id)
    
    # accessToken이 없다면 기존 OAuth 인증결과를 가져옴
    if (is.null(ga_params$access_token)) {
      credentials <- this$views[[ga_params$site_name]]$credentials
    } else {
      credentials <- list(access_token = ga_params$access_token)
    }
    
    # accessToken 정보 설정
    token <- httr::Token2.0$new(app = app, endpoint = endpoint, cache_path = F, 
                                credentials = credentials, params = list(as_header = T)
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
