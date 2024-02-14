#!/bin/bash

echo Docker Compose のバイナリをダウンロード
sudo curl -L "https://github.com/docker/compose/releases/download/v2.8.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo 実行権限を付与
sudo chmod +x /usr/local/bin/docker-compose

# バージョン確認
echo 
echo バージョン確認
echo ---------------------
docker-compose version
echo ---------------------

echo 権限設定
sudo usermod -aG docker ${USER}
