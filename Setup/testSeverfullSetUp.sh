#!/bin/bash

# update_system.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/update_system.sh | sh

# dockerSetup.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/dockerSetup.sh | sh

# docker-composeSetup.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/docker-composeSetup.sh | sh

# Docker設定
sudo docker network create external
# echo dockerの権限を適応するためrebootしてください

# Tailscaleインストール
curl -fsSL https://tailscale.com/install.sh | sh

echo CasaOSのインストールに進んでください。
# echo 
# echo curl -fsSL https://get.casaos.io | sudo bash
# echo sudo chmod 777 /mnt