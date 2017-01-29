library(ggplot2)

ggplot.new <- function(config, dict) {
  # 상수들
  UNITS <- c(-1, 1e0, 1e2, 1e3, 1e4, 1e6, 1e8, 1e12, Inf)
  UNITS.KO <- c('', '', '백', '천', '만', '백만', '억', '조', '')
  
  this <- new.env()

  # ggplot2에서 한글 깨지지 않도록 설정
  text <- ggplot2::theme_get()$text
  text$family <- config$fontfamily
  ggplot2::theme_update(text=text)
  
  # 그래프의 단위를 '백', '천', '만' 등으로 변환
  transformUnit <- function(...) {
    function(x) {
      i <- findInterval(abs(x), UNITS)
      paste0(format(round(x/UNITS[i], 1), trim=T, scientific=F, ...), UNITS.KO[i])
    }
  }
  
  # 차트 객체를 생성
  # - type: { 'bar', 'line' }
  this$render <- function(data, type, dimensions, metrics, title) {
    logger$v('render() started')
    
    # 차트 drawing. 여러 개의 metric을 동시에 나타낼 수 있음
    gg <- ggplot2::ggplot(data, aes_string(x=dimensions[1]))
    gg <- Reduce(function(g, i) {
      color <- ifelse(type == 'bar', 'black', config$colors[i])
      fill <- ifelse(type == 'bar', config$colors[i], 'black')
      g + ggplot2::stat_identity(ggplot2::aes_string(y=metrics[i]), 
                        color=color, fill=fill, 
                        geom=type)
    }, 1:length(metrics), init=gg)
    
    # 차트 제목 및 가로세로축 이름 설정
    xlab <- dict$lookup('dimension', dimensions[1]) 
    ylab <- paste(dict$lookup('metric', metrics), collapse=',')
    logger$v('xlab = %s, ylab = %s', xlab, ylab)
    gg <- gg + ggplot2::xlab(xlab) + ggplot2::ylab(ylab) + ggplot2::ggtitle(title)
   
    # 축 눈금값 변환
    gg <- gg + ggplot2::scale_y_continuous(labels=transformUnit())
    
    # 최종 차트 객체 반환
    return(gg)
  }
  
  # 생성된 차트를 파일로 저장하고 path를 리턴
  this$save <- function(gg, file.name) {
    # 파일저장 디렉토리 없으면 생성
    if (!file.exists(config$dir)) {
      dir.create(config$dir)
    }
    
    file.path <- file.path(config$dir, file.name)
    ggplot2::ggsave(file.path, width=config$width, height=config$height, dpi=config$dpi)
    
    logger$v('Generated figure = %s', file.path)
    file.path
  }
  
  return(this)
}