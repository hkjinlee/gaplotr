# GAplotR 프로젝트

## 개요
- 간단하게 Google Analytics 데이터를 불러와 차트 이미지를 만들어주는 프로젝트

## 초기설정
- etc/config.json.default를 복사해서 etc/config.json 파일 생성
- sites/sample.json.default를 복사/편집해서 sites/{sitename}.json 파일 생성
```{json}
{
  "ga:view_id": "xxxxxxxxx"
}
```

## 파일 설명
- etc/: 전체 환경설정 및 dimension, metric에 대한 사전 파일
- sites/: GA 사이트별 접속정보 (사이트 식별자 및 view_id)
- rserve/: 본 프로젝트를 Rserve 환경에서 이용할 때 활용가능한 helper script들