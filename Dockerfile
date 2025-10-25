# ИСХОДНЫЙ ОБРАЗ
FROM 9hitste/app:latest

# 1. Установка всех утилит, зависимостей и D-Bus
# Добавляем 'dbus-x11' для попытки ручного запуска D-Bus.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget tar netcat bash curl sudo bzip2 psmisc bc \
    dbus-x11 \
    libcanberra-gtk-module libxss1 sed libxtst6 libnss3 libgtk-3-0 \
    libgbm-dev libatspi2.0-0 libatomic1 && \
    rm -rf /var/lib/apt/lists/*

# 2. Установка порта
ENV PORT 10000
EXPOSE 10000

# 3. КОМАНДА ЗАПУСКА (CMD)
CMD bash -c " \
    # --- ШАГ 0: ПОПЫТКА РУЧНОГО ЗАПУСКА D-BUS ---
    # Создаем директорию и запускаем D-Bus в системном режиме, чтобы избежать ошибки /run/dbus/system_bus_socket
    mkdir -p /run/dbus && dbus-daemon --system --fork & \
    
    # --- ШАГ А: НЕМЕДЛЕННЫЙ ЗАПУСК HEALTH CHECK ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p ${PORT} -q 0 -w 1; done & \
    
    # --- ШАГ Б: ЗАПУСК ОСНОВНОГО ПРИЛОЖЕНИЯ (С --no-sandbox) ---
    # Флаги: удалены несовместимые, добавлен --no-sandbox для изоляции и --tmp-dir для совместимости с Cloud Run.
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --session-note=atrei73 --note=atrei73 --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=10G --tmp-dir=/tmp --no-sandbox & \
    
    # Даем программе 70 секунд для установки и запуска
    sleep 70; \
    
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ ---
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/atrei73/9hits-project/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/9hits-project-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/9hits-project-main && \
    echo 'Копирование конфигурации завершено.'; \
    \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    # Ждет завершения фоновых процессов (nh.sh и dbus).
    wait \
"
