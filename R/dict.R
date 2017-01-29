# metric이나 dimension의 이름을 다국어로 표시하기 위한 사전

dict.new <- function() {
  this <- new.env()

  # 여러 개의 사전을 저장할 내부 list
  shelf <- list()
  
  # 사전 추가
  this$add <- function(domain) {
    csvfile <- system.file(file.path('etc', sprintf('%s_name.csv', domain)), package='gaplotr')
    info('adding dictionaries for %s from %s', domain, csvfile)
    shelf[[domain]] <- utils::read.csv(csvfile, comment.char='#', sep='', stringsAsFactors=F)
  }
  
  # 사전에서 단어 lookup
  # name: 'visits' 형태
  this$lookup <- function(domain, name, lang='ko') {
    value <- this$.dict[name, lang]
    ifelse(is.na(value), name, value)
  }
  
  return(this)
}
