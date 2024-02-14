#!/bin/bash

echo システムをアップデートする
sudo apt-get update
sudo apt-get upgrade -y

echo タイムゾーン設定
sudo timedatectl set-timezone Asia/Tokyo

echo net-toolsインストール
# ifconfigなどを使えるように
sudo apt install net-tools