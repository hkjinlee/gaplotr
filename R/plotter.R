#' @import ggplot2
#' @import grDevices
#' @import grid
#' @import gridExtra

plotter.new <- function(config, dict) {
  # 상수들
  UNITS <- c(-1, 1e0, 1e2, 1e3, 1e4, 1e6, 1e8, 1e12, Inf)
  UNITS.KO <- c('', '', '백', '천', '만', '백만', '억', '조', '')
  
  this <- new.env()

  # ggplot2용 한글 설정
  text <- ggplot2::theme_get()$text
  text$family <- config$fontfamily
  ggplot2::theme_update(text=text)
  
  # table용 한글 설정
  text.gpar <- grid::gpar(fontfamily = config$fontfamily, fontsize = 12)
  table.theme <- gridExtra::ttheme_default(base_family = config$fontfamily, base_size = 8)
  
  # 그래프의 단위를 '백', '천', '만' 등으로 변환
  transformUnit <- function(...) {
    function(x) {
      i <- findInterval(abs(x), UNITS)
      paste0(format(round(x/UNITS[i], 1), trim=T, scientific=F, ...), UNITS.KO[i])
    }
  }
  
  # 차트 객체를 생성
  # - type: { 'bar', 'line' }
  this$chartRenderer <- function(data, type, dimensions, metrics, title) {
    info('chartRenderer() started')
    debug('type = %s, dimensions = %s, metrics = %s', type, dimensions, metrics)
    
    # 차트 drawing. 여러 개의 metric을 동시에 나타낼 수 있음
    p <- ggplot2::ggplot(data, ggplot2::aes_string(x=dimensions[1]))
    p <- Reduce(function(g, i) {
      color <- ifelse(type == 'bar', 'black', config$colors[i])
      fill <- ifelse(type == 'bar', config$colors[i], 'black')
      g + ggplot2::stat_identity(ggplot2::aes_string(y=metrics[i]), 
                        color=color, fill=fill, 
                        geom=type)
    }, 1:length(metrics), init=p)
    
    # 차트 제목 및 가로세로축 이름 설정
    xlab <- dict$lookup('dimension', dimensions[1]) 
    ylab <- paste(dict$lookup('metric', metrics), collapse=',')
    debug('xlab = %s, ylab = %s', xlab, ylab)
    p <- p + ggplot2::xlab(xlab) + ggplot2::ylab(ylab) + ggplot2::ggtitle(title)
   
    # 축 눈금값 변환
    p <- p + ggplot2::scale_y_continuous(labels=transformUnit())
    
    # 최종 차트 객체 반환
    plot(p)
  }
  
  # 테이블 객체 생성
  this$tableRenderer <- function(data, dimensions, metrics, title, maxrows = 7) {
    info('tableRederer() started')
    title.grob <- grid::textGrob(label = title, y = -1, gp = text.gpar)
    
    # dimension과 metric 번역
    a <- dict$lookup('dimension', c(dimensions, metrics))
    cols <- dict$lookup('metric', dict$lookup('dimension', c(dimensions, metrics)))
    debug('cols = %s', cols)
      
    table.grob <- gridExtra::tableGrob(head(data, maxrows), 
                                       rows = NULL, cols = cols, 
                                       theme = table.theme
    )
    
    gridExtra::grid.arrange(
      table.grob, 
      top = title.grob
    )
  }
  
  # 생성된 차트를 파일로 저장하고 path를 리턴
  this$save <- function(renderer.func, file.name) {
    info('save() started: filename = "%s"', file.name)
    
    # 파일저장 디렉토리 없으면 생성
    if (!file.exists(config$dir)) {
      dir.create(config$dir)
    }
    
    file.path <- file.path(config$dir, file.name)
    grDevices::png(file.path, width = config$width, height = config$height, units = 'in', res = config$dpi)

    renderer.func()
    grDevices::dev.off()

    info('save() finished')
    file.path
  }
  
  return(this)
}