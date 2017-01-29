# 간단한 로깅 객체

.loglevel <- F

loglevel <- function(loglevel) {
  .loglevel <- loglevel
} 

# 디버깅용 로그메시지 출력용 함수
v <- function(...) {
  if (.loglevel) {
    cat(base::date(), class(this), sprintf(...), '\n', file=stderr())
  }
}
