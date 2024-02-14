#!/bin/bash

# update_system.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/update_system.sh | sh

# dockerSetup.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/dockerSetup.sh | sh

# docker-composeSetup.sh
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/docker-composeSetup.sh | sh

# Tailscaleインストール
# curl -fsSL https://tailscale.com/install.sh | sh
# ログインしないといけないので、一括から外しました。

echo dockerの権限を適応するためrebootしてください