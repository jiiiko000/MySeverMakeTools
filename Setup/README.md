# Linux　セットアップ用

SSHが許可されてない場合
https://www.kkaneko.jp/tools/server/pubkey.html

---
面倒なので以下のコマンドを一括実施するsh
```
https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/fullSetUp.sh
```
---

インストール  
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/update_system.sh | sh
```
※備忘
自作したshはRAWで読み込む  
改行コードはLFにする。Windowsで作成すると、改行コードが違うから注意。

---
dockerインストール　※公式のインストーラー
```
curl https://get.docker.com | sh
```
自作  
基本こっちで良さげ
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/dockerSetup.sh | sh
```

docker-compose
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMake/main/Setup/docker-composeSetup.sh | sh
```
---
Tailscale  
VPNに参加させるときに実行
```
curl -fsSL https://tailscale.com/install.sh | sh
```
起動
```
sudo tailscale up
```