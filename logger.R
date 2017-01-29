# 간단한 로깅 객체

GAplotR.logger <- function(verbose) {
  this <- new.env()
  class(this) <- 'GAplotR.logger'
  
  # 디버깅용 로그메시지 출력용 함수
  this$v <- function(...) {
    if (verbose) {
      cat(base::date(), class(this), sprintf(...), '\n', file=stderr())
    }
  }
  
  return(this)
}