#!/usr/bin/env bash
set -euo pipefail

# === Конфиг — проверь перед запуском ===
XAMPP_URL="${XAMPP_URL:-https://download-url-на-актуальный-xampp-8.x.run}"  # замени на актуальную ссылку
USE_PORT_8080="${USE_PORT_8080:-auto}"   # yes|no|auto — auto попробует детектить конфликт 80
TZ_REGION="${TZ_REGION:-Asia/Yekaterinburg}"
LOCALES_ENABLE="${LOCALES_ENABLE:-ru_RU.UTF-8 en_US.UTF-8}"
LOCALE_DEFAULT="${LOCALE_DEFAULT:-ru_RU.UTF-8}"

# === Проверки окружения ===
if [[ ! -t 1 ]]; then
  echo "Предпочтительно запускать в интерактивной сессии."
fi

if [[ $EUID -eq 0 ]]; then
  echo "Пожалуйста, запусти скрипт НЕ от root. sudo будет вызван по мере необходимости."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "Устанавливаю sudo..."
  apt update && apt install -y sudo
fi

# === Обновления и базовые пакеты ===
echo "Обновляю систему и ставлю базовый набор..."
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y ca-certificates curl wget git gnupg lsb-release \
    build-essential pkg-config zip unzip tar nano vim htop locales unattended-upgrades

# === Включение systemd в WSL ===
echo "Включаю systemd через /etc/wsl.conf (потребуется wsl --shutdown в Windows)..."
if ! grep -q '^

\[boot\]

' /etc/wsl.conf 2>/dev/null; then
  echo "[boot]" | sudo tee /etc/wsl.conf >/dev/null
fi
if ! grep -q '^systemd=true' /etc/wsl.conf; then
  echo "systemd=true" | sudo tee -a /etc/wsl.conf >/dev/null
fi
echo "ВНИМАНИЕ: после окончания скрипта выполните в PowerShell:  wsl --shutdown  и заново откройте Debian."

# === Локали и часовой пояс ===
echo "Настраиваю локали и часовой пояс..."
sudo sed -i 's/^# *\('"$(echo $LOCALES_ENABLE | sed 's/ /\\|/g')"'\) UTF-8/\1 UTF-8/' /etc/locale.gen || true
for loc in $LOCALES_ENABLE; do
  if ! grep -q "^$loc UTF-8" /etc/locale.gen; then
    echo "$loc UTF-8" | sudo tee -a /etc/locale.gen >/dev/null
  fi
done
echo "LANG=$LOCALE_DEFAULT" | sudo tee /etc/default/locale >/dev/null
sudo locale-gen
sudo update-locale LANG="$LOCALE_DEFAULT"
sudo timedatectl set-timezone "$TZ_REGION" || true

# === Unattended-upgrades (активация) ===
echo "Активирую unattended-upgrades..."
sudo dpkg-reconfigure -fnoninteractive unattended-upgrades || true

# === Установка XAMPP ===
if [[ "$XAMPP_URL" == https://download-url-на-актуальный-xampp-8.x.run ]]; then
  echo "ОШИБКА: Не задана корректная ссылка XAMPP_URL. Отредактируй переменную вверху скрипта."
  exit 1
fi

mkdir -p "$HOME/Downloads"
cd "$HOME/Downloads"
echo "Скачиваю XAMPP из: $XAMPP_URL"
curl -fLo xampp.run "$XAMPP_URL"
chmod +x xampp.run
echo "Устанавливаю XAMPP в режиме текста..."
sudo ./xampp.run --mode text

# === Управляющий скрипт и старт ===
sudo ln -sf /opt/lampp/lampp /usr/local/bin/lampp
echo "Запускаю XAMPP..."
sudo lampp start || true
sleep 2
sudo lampp status || true

# === Опциональное переключение порта Apache на 8080 ===
needs8080="no"
if [[ "$USE_PORT_8080" == "yes" ]]; then
  needs8080="yes"
elif [[ "$USE_PORT_8080" == "auto" ]]; then
  # Простейшее определение конфликта порта 80
  if ss -lnt | awk '{print $4}' | grep -qE '(^|:)80$'; then
    needs8080="yes"
  fi
fi

if [[ "$needs8080" == "yes" ]]; then
  echo "Выявлен/запрошен конфликт порта 80. Переключаю Apache на 8080..."
  sudo sed -i 's/^Listen 80$/Listen 8080/' /opt/lampp/etc/httpd.conf
  sudo sed -i 's/:80>/:8080>/' /opt/lampp/etc/extra/httpd-vhosts.conf 2>/dev/null || true
  sudo lampp restart || true
  echo "Теперь открывай http://localhost:8080/"
else
  echo "Порт 80 оставлен без изменений. Открывай http://localhost/"
fi

# === info.php ===
echo "Создаю /opt/lampp/htdocs/info.php ..."
echo '<?php phpinfo();' | sudo tee /opt/lampp/htdocs/info.php >/dev/null

# === Composer с PHP из XAMPP ===
echo "Ставлю Composer..."
mkdir -p "$HOME/.local/bin"
/opt/lampp/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
/opt/lampp/bin/php composer-setup.php --install-dir="$HOME/.local/bin" --filename=composer
rm -f composer-setup.php

# === Алиасы и PATH ===
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
if ! grep -q 'alias php="/opt/lampp/bin/php"' "$HOME/.bashrc"; then
  {
    echo 'alias php="/opt/lampp/bin/php"'
    echo 'alias phpize="/opt/lampp/bin/phpize"'
    echo 'alias php-config="/opt/lampp/bin/php-config"'
  } >> "$HOME/.bashrc"
fi

echo
echo "=== Готово ==="
echo "- Проверь: composer --version (после source ~/.bashrc)"
echo "- Проверь: php -v (должен быть PHP из XAMPP)"
echo "- Проверь браузером: http://localhost/ или http://localhost:8080/ (если переключили порт)"
echo "- Для активации systemd: в PowerShell выполни  wsl --shutdown  и заново открой Debian."
