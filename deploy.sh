#!/usr/bin/env sh
# 發生錯誤時終止
set -e
# 建置
npm run build
# 移動到輸出目錄
cd dist
# 部署到 gh-pages 分支
git init
git checkout -b main
git add -A
git commit -m 'deploy'
# 記得改成你的 GitHub 網址
git push -f https://github.com/你的帳號/my-countdown.git main:gh-pages
cd -