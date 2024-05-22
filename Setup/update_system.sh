#!/bin/bash

echo システムをアップデートする
sudo apt-get update
sudo apt-get upgrade -y

echo タイムゾーン設定
sudo timedatectl set-timezone Asia/Tokyo

echo net-toolsインストール
# ifconfigなどを使えるように
sudo apt install net-tools

# 日本語の言語パッケージを適応
sudo apt install language-pack-ja language-pack-ja-base
locale -a
sudo update-locale LANG=ja_JP.UTF-8
locale -a