# GA API 호출을 최소화하기 위해 local file로 데이터를 저장해두는 캐시
# cache/{site.id}/{request json의 md5} 형태로 저장

library(digest)

cache.new <- function(config) {
  this <- new.env()

  # 해당 데이터가 캐시되어있으면 그대로 리턴하고, 없으면 get.func를 호출해 생성
  # 캐시 조건: 파일이 존재하고 최종변경시각이 expire.hour 이내
  this$get <- function(site.id, obj, get.func) {
    debug('get() started')
    
    cache.dir <- file.path(config$dir, site.id)
    if (!file.exists(cache.dir)) {
      dir.create(cache.dir, recursive=T)
    }
    cache.file <- file.path(cache.dir, digest::digest(obj, algo='md5'))
    
    if (file.exists(cache.file) & Sys.time() - file.info(cache.file)$mtime > config$expire.hour) {
      info('cache valid for %s/%s', site.id, cache.file)
      load(cache.file)
    } else {
      info('cache invalid or old for %s/%s', site.id, cache.file)
      data <- get.func(site.id, obj)
      save(data, file=cache.file)
    }
    
    debug('get() : data = %s', data)
    data
  }

  return(this)
}