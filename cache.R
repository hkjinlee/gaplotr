# GA API 호출을 최소화하기 위해 local file로 데이터를 저장해두는 캐시
# cache/{site.id}/{request json의 md5} 형태로 저장

library(digest)

GAplotR.cache <- function(config, logger) {
  this <- new.env()
  class(this) <- 'GAplotR.cache'

  logger <- logger
  
  # 해당 데이터가 캐시되어있으면 그대로 리턴하고, 없으면 get.func를 호출해 생성
  # 캐시 조건: 파일이 존재하고 최종변경시각이 expire.hour 이내
  this$get <- function(site.id, obj, get.func) {
    logger$v('get() started')
    
    cache.dir <- file.path(config$dir, site.id)
    if (!file.exists(cache.dir)) {
      dir.create(cache.dir, recursive=T)
    }
    cache.file <- file.path(cache.dir, digest(obj, algo='md5'))
    
    logger$v('cache.file = %s', cache.file)
    
    if (file.exists(cache.file) & Sys.time() - file.info(cache.file)$mtime > config$expire.hour) {
      logger$v('cache valid')
      load(cache.file)
    } else {
      logger$v('cache invalid or old')
      data <- get.func(site.id, obj)
      save(data, file=cache.file)
    }
    
    logger$v('get() : data = %s', data)
    data
  }

  return(this)
}