#'
#' @title gaplotr
#' @description Generates PNG charts from Google Analytics API
#' @details etc

#' @import jsonlite
#' @import rga

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
  
  # 사이트 정보 로딩 및 OAuth 실행
  # 'onestore_app'이라는 view가 있을 경우
  # - this$views는 list
  # - this$views$onestore_app은 environment
  # - this$views$onestore_app$view_id에 view id 저장
  # - this$views$onestore_app$rga에 rga 객체 저장
  this$views <- list()
  Map(function(view.json) {
    info('loading GA info from %s', view.json)
    view.name <- gsub('\\.json$', '', basename(view.json))
    dir <- dirname(view.json)

    # JSON파일로부터 환경 불러옴
    view.env <- list2env(jsonlite::fromJSON(view.json))

    # OAuth 인증
    info('OAuth started: view.name = %s', view.name)
    rga::rga.open(instance = 'ga', 
             client.id = config$ga$client_id,
             client.secret = config$ga$client_secret,
             where = file.path(dir, paste0(view.name, '.rga')),
             envir = view.env)
    info('OAuth ended for %s', view.name)
    
    this$views[[view.name]] <- view.env
  }, list.files(path = config$ga$dir, full.names = T, pattern = '\\.json$')
  )
  info('loading GA info finished. # of views = %d', length(this$views))

  # GA로부터 데이터 조회
  getData <- function(view.name, ...) {
    args <- list(...)[[1]]
    debug('getData(): view.name = %s, args = %s', view.name, args)
    
    view.env <- this$views[[view.name]]
    view.id <- view.env$view_id
    ga <- view.env$ga
    
    data <- ga$getData(ids = view.id,
                       start.date = args[['start-date']], 
                       end.date = args[['end-date']],
                       dimensions = paste(args$dimensions, collapse=','), 
                       metrics = paste(args$metrics, collapse=',')
    )
    debug('getData(): data = %s', data)
    data
  }

  # 차트 이미지를 생성.
  # plot을 그린 뒤 저장하는 것이 아니고, 저장위치(파일)를 정해두고 그쪽에 그리는 것임.
  # - type: { 'bar', 'line', 'table' }
  this$generateChart <- function(view.name, type, params, title, filename) {
    debug('generateChart(): view.name=%s, type=%s, params=%s', view.name, type, params)

    # 차트용 데이터 fetch. 유효한 캐쉬가 없으면 getData()를 호출하여 직접 가져옴
    data <- cache$get(view.name, params, getData)
    
    # dimension과 metric 추출 ('ga:visits' -> 'visit'로 변경)
    dimensions <- gsub('^ga:', '', params$dimensions)
    metrics <- gsub('^ga:', '', params$metrics)

    # 차트 renderer 지정
    renderer.func <- function() {
      if (type != 'table') {
        plotter$chartRenderer(data, type, dimensions, metrics, title)
      } else {
        plotter$tableRenderer(data, dimensions, metrics, title)
      }
    }

    # 차트 저장
    file.path <- plotter$save(renderer.func, filename)
    
    return(file.path)
  }
  
  return(this)
}