# 디버깅용 로그메시지 출력용 함수
v <- function(...) {
  verbose <- get0('verbose')
  if (verbose) {
    cat(base::date(), class(this), sprintf(...), '\n', file=stderr())
  }
}