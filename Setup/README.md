# Linux　セットアップ用

SSHが許可されてない場合
https://www.kkaneko.jp/tools/server/pubkey.html

---
面倒なので以下のコマンドを一括実施するsh
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/fullSetUp.sh | sh
```
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/testSeverfullSetUp.sh | sh
```
---
## 最新にUPDATE
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/update_system.sh | sh
```
※備忘
自作したshはRAWで読み込む  
改行コードはLFにする。Windowsで作成すると、改行コードが違うから注意。

---
## docker
※公式のインストーラー
```
curl https://get.docker.com | sh
```
自作  
基本こっちで良さげ
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/dockerSetup.sh | sh
```

docker-compose
```
curl -fsSL https://raw.githubusercontent.com/jiiiko000/MySeverMakeTools/main/Setup/docker-composeSetup.sh | sh
```
sudoなしでdockerコマンド打てるように仕込んであるが、再起動しないと反映されないのでする。
```
sudo reboot
```

---
## Tailscale  
VPNに参加させるときに実行
```
curl -fsSL https://tailscale.com/install.sh | sh
```
起動
```
sudo tailscale up
```