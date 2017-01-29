# GA API 호출을 최소화하기 위해 local file로 데이터를 저장해두는 캐시
# cache/{site.id}/{request json의 md5} 형태로 저장

library(digest)

GAplotR.cache <- function(config.cache, debug=T) {
  this <- new.env()
  class(this) <- 'GAplotR.cache'
  
  this$debug <- debug
  
  # 디버깅용 로그메시지 출력용 함수
  v <- function(...) {
    if (this$debug) {
      cat(date(), class(this), sprintf(...), '\n', file=stderr())
    }
  }
  
  # 해당 데이터가 캐시되어있으면 그대로 리턴하고, 없으면 get.func를 호출해 생성
  # 캐시 조건: 파일이 존재하고 최종변경시각이 expire.hour 이내
  this$get <- function(site.id, obj, get.func) {
    v('get() started')
    
    cache.dir <- file.path(config.cache$dir, site.id)
    if (!file.exists(cache.dir)) {
      dir.create(cache.dir, recursive=T)
    }
    cache.file <- file.path(cache.dir, digest(obj, algo='md5'))
    
    v('cache.file = %s', cache.file)
    
    if (file.exists(cache.file) & Sys.time() - file.info(cache.file)$mtime > config.cache$expire.hour) {
      v('cache valid')
      load(cache.file)
    } else {
      v('cache invalid or old')
      data <- get.func(site.id, obj)
      save(data, file=cache.file)
    }
    
    v('get() : data = %s', data)
    data
  }

  return(this)
}