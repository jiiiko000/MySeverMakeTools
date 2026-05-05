#!/bin/bash

set -u

SCRIPT_NAME="$(basename "$0")"
BACKUP_SUFFIX="bak.$(date +%Y%m%d_%H%M%S)"
CHANGED_FILES=()

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*"
}

error() {
  echo "[ERROR] $*" >&2
}

confirm() {
  local message="$1"
  local answer
  read -r -p "$message [y/N]: " answer
  case "$answer" in
    y|Y|yes|YES)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

require_root() {
  if [ "${EUID}" -ne 0 ]; then
    error "このスクリプトは root で実行してください。例: sudo bash ${SCRIPT_NAME}"
    exit 1
  fi
}

add_changed_file() {
  local file="$1"
  local existing
  for existing in "${CHANGED_FILES[@]:-}"; do
    if [ "$existing" = "$file" ]; then
      return 0
    fi
  done
  CHANGED_FILES+=("$file")
}

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "${file}.${BACKUP_SUFFIX}"
    log "バックアップ作成: ${file}.${BACKUP_SUFFIX}"
  fi
}

show_ip_addresses() {
  log "IPアドレスを確認します"
  ip a || warn "ip コマンドの表示に失敗しました"
}

ensure_openssh_server() {
  if dpkg -s openssh-server >/dev/null 2>&1; then
    log "openssh-server は既にインストールされています"
    return 0
  fi

  warn "openssh-server が見つかりません"
  if confirm "apt update と openssh-server のインストールを実行しますか?"; then
    apt update && apt install openssh-server -y
  else
    error "openssh-server が無いとSSHを有効化できません"
    exit 1
  fi
}

ensure_ssh_service() {
  log "ssh サービスを有効化します"
  systemctl enable --now ssh
  systemctl status ssh --no-pager || warn "ssh サービス状態の取得に失敗しました"
}

show_port_status() {
  log "22番ポートの待受状態を確認します"
  if ! ss -tlnp | grep 22; then
    warn "22番ポートで LISTEN が確認できませんでした"
  fi
}

show_ufw_status() {
  log "UFW の状態を表示します（参考情報）"
  if ! ufw status; then
    warn "ufw status の取得に失敗しました"
  fi
}

update_password_authentication_file() {
  local file="$1"

  if grep -Eq '^[[:space:]]*PasswordAuthentication[[:space:]]+yes([[:space:]]|$)' "$file"; then
    log "既に PasswordAuthentication yes: $file"
    return 0
  fi

  backup_file "$file"

  if grep -Eq '^[[:space:]#]*PasswordAuthentication[[:space:]]+' "$file"; then
    sed -Ei 's/^[[:space:]#]*PasswordAuthentication[[:space:]]+.*/PasswordAuthentication yes/' "$file"
    log "PasswordAuthentication を yes に変更: $file"
  else
    printf '\nPasswordAuthentication yes\n' >> "$file"
    log "PasswordAuthentication yes を追記: $file"
  fi

  add_changed_file "$file"
}

ensure_password_authentication() {
  local conf_dir="/etc/ssh/sshd_config.d"
  local primary_file="${conf_dir}/60-cloudimg-settings.conf"
  local file
  local found_conf=0

  log "PasswordAuthentication の設定を確認します"

  grep -R PasswordAuthentication /etc/ssh/ || true

  if [ -d "$conf_dir" ]; then
    for file in "$conf_dir"/*.conf; do
      if [ -e "$file" ]; then
        found_conf=1
        update_password_authentication_file "$file"
      fi
    done
  fi

  if [ "$found_conf" -eq 0 ]; then
    mkdir -p "$conf_dir"
    : > "$primary_file"
    log "設定ファイルを新規作成: $primary_file"
    update_password_authentication_file "$primary_file"
  fi
}

ensure_root_login() {
  local sshd_config="/etc/ssh/sshd_config"

  log "PermitRootLogin yes を設定します"
  backup_file "$sshd_config"

  if grep -Eq '^[[:space:]]*PermitRootLogin[[:space:]]+yes([[:space:]]|$)' "$sshd_config"; then
    log "既に PermitRootLogin yes: $sshd_config"
    return 0
  fi

  if grep -Eq '^[[:space:]#]*PermitRootLogin[[:space:]]+' "$sshd_config"; then
    sed -Ei 's/^[[:space:]#]*PermitRootLogin[[:space:]]+.*/PermitRootLogin yes/' "$sshd_config"
    log "PermitRootLogin を yes に変更: $sshd_config"
  else
    printf '\nPermitRootLogin yes\n' >> "$sshd_config"
    log "PermitRootLogin yes を追記: $sshd_config"
  fi

  add_changed_file "$sshd_config"
}

validate_and_restart_ssh() {
  log "sshd の構文を確認します"
  if ! sshd -t; then
    error "sshd -t に失敗したため、ssh の再起動を中止します"
    exit 1
  fi

  log "ssh サービスを再起動します"
  systemctl restart ssh
}

show_final_status() {
  local current_ip

  log "最終状態を確認します"
  sshd -T | grep passwordauthentication || warn "passwordauthentication の取得に失敗しました"
  sshd -T | grep permitrootlogin || warn "permitrootlogin の取得に失敗しました"

  echo
  echo "変更したファイル一覧:"
  if [ "${#CHANGED_FILES[@]}" -eq 0 ]; then
    echo "- 変更なし"
  else
    printf -- '- %s\n' "${CHANGED_FILES[@]}"
  fi

  echo
  current_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  if [ -n "$current_ip" ]; then
    echo "接続例: ssh root@${current_ip}"
  else
    echo "接続例: ssh root@<IPアドレス>"
  fi
}

main() {
  require_root

  echo "Proxmox + Ubuntu Server 向け SSH 復旧シェル"
  echo "PasswordAuthentication yes / PermitRootLogin yes を設定します"
  echo

  if ! confirm "このまま処理を開始しますか?"; then
    warn "処理を中止しました"
    exit 0
  fi

  show_ip_addresses
  ensure_openssh_server
  ensure_ssh_service
  show_port_status
  show_ufw_status
  ensure_password_authentication
  ensure_root_login
  validate_and_restart_ssh
  show_final_status
}

main "$@"
