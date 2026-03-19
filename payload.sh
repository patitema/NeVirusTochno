WORK_DIR="/tmp/mysql"

# Генерация имени
generate_name() {
    local prefixes=("ibdata" "mysql-bin" "binlog" "innodb" "relay-log" "redo" "ibtmp" "undo")
    local prefix=${prefixes[$RANDOM % ${#prefixes[@]}]}
    local number=$RANDOM$RANDOM
    echo "${prefix}${number}"
}

# Создание директории
find_dir() {
    if [ ! -d "$WORK_DIR" ]; then
        mkdir -p "$WORK_DIR"
        chmod 700 "$WORK_DIR"
    fi
}

# Запуск замаскированного процесса
process() {
    local filename=$(generate_name)
    local filepath="$WORK_DIR/$filename"
    
    # Создаем файл-заглушку
    echo "#!/bin/bash" > "$filepath"
    echo "while true; do sleep 60; done" >> "$filepath"
    chmod +x "$filepath"
    
    # Запускаем в фоне
    "$filepath" &
}

# 4. Имитация сетевой активности сurl
simulate_network() {

    (while true; do sleep 100; done) &

}

main() {
    find_dir
    
    for i in {1..8}; do
        process
    done
    
    simulate_network
}

main