#!/usr/bin/env Rscript

library(Rserve)

# 공통 환경파일 위치는 $HOME/workspace/server/scripts/env.R
env_file_path <- sprintf('%s/workspace/server/scripts/env.R', Sys.getenv('HOME'))

args <- sprintf('--RS-source %s', env_file_path)
Rserve(args=args)
