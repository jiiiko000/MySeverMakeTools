#!/bin/bash

echo 依存関係のあるパッケージのインストール
sudo apt install apt-transport-https ca-certificates curl software-properties-common

echo Dockerの公式GPGキーとリポジトリを追加
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo Dockerのリポジトリをシステムに追加
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo Dockerエンジンのインストール
sudo apt update
sudo apt install docker-ce -y
sudo apt install docker-ce-cli -y
sudo apt install containerd.io -y

echo ユーザーをDockerグループに追加
sudo usermod -aG docker ${USER}

echo Dockerサービスの開始と有効化
sudo systemctl start docker
sudo systemctl enable docker

echo  
echo 以下コマンドで確認
echo docker run hello-world