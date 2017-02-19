library(httr)

DEFAULT_AUTH_SCOPES <- 'https://www.googleapis.com/auth/analytics.readonly'

auth.new <- function(config) {
  this <- new.env()
  
  # OAuth 인증용 기본객체 생성
  app <- httr::oauth_app('google', key = config$client_id, secret = config$client_secret)
  endpoint <- httr::oauth_endpoints('google')
  
  # googleAuthR 기본설정
  options(googleAuthR.client_id = config$client_id,
          googleAuthR.client_secret = config$client_secret,
          googleAuthR.scopes.selected = DEFAULT_AUTH_SCOPES,
          googleAuthR.httr_oauth_cache = F)
  
  # 사이트 정보 로딩 및 OAuth 실행
  # 'onestore_app'이라는 account가 있을 경우, 
  # - views$onestore_app$view_id가 원스토어의 GA view id
  # - views$onestore_app$access_token
  # - views$onestore_app$refresh_token
  this$views <- list()
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
    info('OAuth ended')
    
    # 파일 저장
    write(jsonlite::toJSON(view, auto_unbox = T, pretty = T), file = view.json)
    
    this$views[[view$site_name]] <- view
  }, list.files(path = config$dir, full.names = T, pattern = '\\.json$'))
  info('loading GA info finished. # of views = %d', length(this$views)) 
  
  this$doAuth <- function(ga_params = list(site_name = null, access_token = null, refresh_token = null)) {
    # accessToken이 없다면 기존 OAuth 인증결과를 가져옴
    if (is.null(ga_params$access_token)) {
      credentials <- this$views[[ga_params$site_name]]$credentials
    } else {
      credentials <- list(access_token = ga_params$access_token, refresh_token = ga_params$refresh_token)
    }
    
    # Token 정보 설정
    token <- httr::Token2.0$new(app = app, endpoint = endpoint, cache_path = F, 
                                credentials = credentials, 
                                params = list(as_header = T,
                                              use_oob = F,
                                              scope = DEFAULT_AUTH_SCOPES)
    )
    
    # Token refresh
    if (token$can_refresh()) {
      token$refresh()
    }
    
    googleAuthR::gar_auth(token = token)
  }
  
  return(this)
}
