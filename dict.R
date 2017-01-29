# metric이나 dimension의 이름을 다국어로 표시하기 위한 사전

GAplotR.dict <- function(csvfile) {
  this <- new.env()
  class(this) <- 'gaplotr.dict'
  
  this$.dict <- read.csv(csvfile, comment.char='#', sep='', stringsAsFactors=F)
  
  # name: 'visits' 형태
  this$lookup <- function(name, lang='ko') {
    value <- this$.dict[name, lang]
    ifelse(is.na(value), name, value)
  }
  
  return(this)
}