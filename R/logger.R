# 간단한 로깅 유틸리티

LOGLEVEL <- setNames(1:4, c('error', 'warn', 'info', 'debug'))
.loglevel <- "warn"
.out <- stderr()

loglevel <- function(loglevel) {
  cat(base::date(), ' [INFO] loglevel set to "', loglevel, '"\n', sep='', file=.out)
  .loglevel <- LOGLEVEL[loglevel]
} 

# 디버깅용 로그메시지 출력용 함수
log <- function(loglevel.out, prefix, ...) {
  if (loglevel.out <= .loglevel) {
    cat(base::date(), prefix, sprintf(...), '\n', file=.out)
  }
}

error <- function(...) log(1, '[ERROR]', ...)
warn  <- function(...) log(2, '[WARN]', ...)
info  <- function(...) log(3, '[INFO]', ...)
debug <- function(...) log(4, '[DEBUG]', ...)