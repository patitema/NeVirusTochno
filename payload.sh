WORK_DIR="/tmp/mysql"
LOG_DIR="/tmp"

# 1. Генерация имени файла под видом MySQL
generate_name() {
    local prefixes=("ibdata" "mysql-bin" "binlog" "innodb" "relay-log" "redo" "ibtmp" "undo")
    local prefix=${prefixes[$RANDOM % ${#prefixes[@]}]}
    local number=$RANDOM$RANDOM
    echo "${prefix}${number}"
}

# 2. Создание директории
find_dir() {
    if [ ! -d "$WORK_DIR" ]; then
        mkdir -p "$WORK_DIR"
        chmod 700 "$WORK_DIR"
    fi
}

# 3. Логирование активности
log_activity() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] mysql-slow.log rotation" >> "$LOG_DIR/mysql-slow.log"
}

# Сбор информации о системе
collect_info() {
    local info_file="$LOG_DIR/.mysql-info-$(date +%Y%m%d).log"
    {
        echo "System Info"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo "Processes: $(ps aux | wc -l)"
    } >> "$info_file"
    touch "$LOG_DIR/.mysql_last_run"
}

# Запуск замаскированного процесса
process() {
    local filename=$(generate_name)
    local filepath="$WORK_DIR/$filename"
    
    # Создаем файл-заглушку с бесконечным циклом
    echo "#!/bin/bash" > "$filepath"
    echo "while true; do sleep 60; done" >> "$filepath"
    chmod +x "$filepath"
    
    # Запускаем в фоне
    "$filepath" &
}

# Имитация сетевой активности (curl)
simulate_network() {
    # Имитируем зависший процесс скачивания
    (while true; do sleep 100; done) &
}

main() {
    find_dir
    
    # Записываем логи при каждом запуске
    log_activity
    collect_info
    
    # Создаем 8 процессов-масок
    for i in {1..8}; do
        process
    done
    
    # Добавляем фейковый curl
    simulate_network
}

main