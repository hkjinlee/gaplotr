# 모든 접속에서 공통적으로 사용되는 코드
# 수정 뒤에는 서버 재기동 필요: ./stop_server.R; ./start_server.R 

source('gaplotr.R')

gaplotr <- GAplotR(file.path('etc', 'config.json'))