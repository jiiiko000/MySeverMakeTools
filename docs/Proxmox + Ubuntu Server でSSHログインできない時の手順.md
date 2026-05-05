🧭 Proxmox + Ubuntu Server でSSHログインできない時の手順（テンプレ）

🎯 ゴール

* SSHでログインできる状態にする（パスワード or 鍵）

⸻

① コンソールからログイン（必須）

ProxmoxのVMコンソールから入る

⸻

② IPアドレス確認

ip a

👉 192.168.x.x をメモ

⸻

③ SSHサービス確認

systemctl status ssh

❌ 無い場合

sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh

⸻

④ ポート確認

ss -tlnp | grep 22

👉 出ればOK（LISTEN）

⸻

⑤ UFW確認（今回は関係なし）

sudo ufw status

👉 inactiveならスルー

⸻

🔴 ⑥ 【今回のハマりポイント】SSH設定の上書き

Ubuntu 24.04 で最も重要👇

grep -R PasswordAuthentication /etc/ssh/

よくある原因

/etc/ssh/sshd_config.d/60-cloudimg-settings.conf
PasswordAuthentication no

👉 これが全てを壊す犯人

⸻

⑦ 修正

sudo nano /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

変更：

PasswordAuthentication yes

⸻

⑧ rootログイン許可（必要なら）

sudo nano /etc/ssh/sshd_config
PermitRootLogin yes

⸻

⑨ 反映

sudo sshd -t
sudo systemctl restart ssh

⸻

⑩ 最終確認

sshd -T | grep passwordauthentication

👉 yes になっていればOK

⸻

⑪ 接続

ssh ユーザー名@IP

または

ssh root@IP

⸻

💥 今回の原因まとめ

項目	状態
SSHサービス	✅ 正常
ポート22	✅ 開いてる
UFW	❌ 無関係
rootログイン	許可済み
PasswordAuthentication	❌ cloud-initで無効化されていた

⸻

🧠 本質

Ubuntu 24.04（特にcloud image）は

👉 デフォルトで「鍵認証のみ」前提

そのため：

* パスワードログイン → 無効
* rootログイン → 制限あり

⸻

👍 次回つまずかないための最短コマンド

VM作ったら最初にこれ👇

sudo apt update
sudo apt install openssh-server -y
sudo sed -i 's/PasswordAuthentication no/yes/g' /etc/ssh/sshd_config.d/*.conf
sudo systemctl restart ssh

⸻

🔐 補足（おすすめ構成）

本来は👇が安全

* パスワードログイン → OFF
* rootログイン → OFF
* 鍵認証のみ

⸻

