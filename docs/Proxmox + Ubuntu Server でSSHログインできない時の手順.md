# 🧭 Proxmox + Ubuntu Server でSSHログインできない時の手順

## 🎯 ゴール

SSHでログインできる状態にする（パスワード or 鍵）

---

## ① コンソールからログイン（必須）

ProxmoxのVMコンソールから入る

---

## ② IPアドレス確認

```bash
ip a
```

👉 `192.168.x.x` をメモ

---

## ③ SSHサービス確認

```bash
systemctl status ssh
```

### ❌ SSHがインストールされていない場合

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

---

## ④ ポート確認

```bash
ss -tlnp | grep 22
```

👉 出力されればOK（LISTEN状態）

---

## ⑤ UFW確認（今回は関係なし）

```bash
sudo ufw status
```

👉 `inactive` ならスルー

---

## 🔴 ⑥ 【今回のハマりポイント】SSH設定の上書き

**Ubuntu 24.04 で最も重要** 👇

```bash
grep -R PasswordAuthentication /etc/ssh/
```

### よくある原因

`/etc/ssh/sshd_config.d/60-cloudimg-settings.conf` に以下の設定がある：

```
PasswordAuthentication no
```

👉 **これが全てを壊す犯人**

---

## ⑦ 修正

```bash
sudo nano /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
```

変更内容：

```
PasswordAuthentication yes
```

---

## ⑧ rootログイン許可（必要なら）

```bash
sudo nano /etc/ssh/sshd_config
```

以下の行を追加／編集：

```
PermitRootLogin yes
```

---

## ⑨ 反映

```bash
sudo sshd -t
sudo systemctl restart ssh
```

---

## ⑩ 最終確認

```bash
sshd -T | grep passwordauthentication
```

👉 `yes` になっていればOK

---

## ⑪ 接続

```bash
ssh ユーザー名@IP
```

または

```bash
ssh root@IP
```

---

## 💥 今回の原因まとめ

| 項目 | 状態 |
|------|------|
| SSHサービス | ✅ 正常 |
| ポート22 | ✅ 開いてる |
| UFW | ❌ 無関係 |
| rootログイン | 許可済み |
| PasswordAuthentication | ❌ cloud-initで無効化されていた |

---

## 🧠 本質

Ubuntu 24.04（特にcloud image）は **デフォルトで「鍵認証のみ」前提**。

そのため：

- パスワードログイン → 無効
- rootログイン → 制限あり

---

## 👍 次回つまずかないための最短コマンド

VM作ったら最初にこれ 👇

```bash
sudo apt update
sudo apt install openssh-server -y
sudo sed -i 's/PasswordAuthentication no/yes/g' /etc/ssh/sshd_config.d/*.conf
sudo systemctl restart ssh
```

---

## 🔐 補足（おすすめ構成）

本来は以下の設定が安全：

- パスワードログイン → OFF
- rootログイン → OFF
- **鍵認証のみ**
