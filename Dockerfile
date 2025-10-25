# ИСХОДНЫЙ ОБРАЗ
FROM 9hitste/app:latest

# 1. Установка общих утилит
# Используем 'netcat' для большей совместимости, если 'netcat-openbsd' не подходит
RUN apt-get update && \
    apt-get install -y wget tar netcat bash && \
    rm -rf /var/lib/apt/lists/*

# 2. Установка порта
ENV PORT 8000
EXPOSE 8000

# 3. КОМАНДА ЗАПУСКА (CMD)
# Выполняется при запуске контейнера
CMD bash -c " \
    # --- ШАГ А: ПЕРВЫЙ ЗАПУСК /nh.sh (для установки и создания директорий) ---
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --session-note=atrei73_back4app --note=atrei73_back4app --schedule-reset=1 --cache-del=200 --create-swap=10G & \
    
    # Даем программе 135 секунд, чтобы полностью установиться и создать директории
    sleep 135; \
    
    # --- ШАГ Б: КОПИРОВАНИЕ КОНФИГОВ (После установки программы) ---
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/atrei73/9hits-project/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/9hits-project-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/9hits-project-main && \
    echo 'Копирование конфигурации завершено.'; \
    
    # --- ШАГ В: ЗАПУСК HEALTH CHECK ---
    # Используем 'nc' без явного пути. Теперь он должен быть в PATH.
    # Если это не сработает, замените 'nc' на '/bin/nc'
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p ${PORT} -q 0 -w 1; done & \
    \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    tail -f /dev/null \
"
