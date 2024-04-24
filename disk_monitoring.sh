#!/bin/bash

# Путь к файлу журнала
LOG_FILE="/var/log/disk_monitoring.log"

# Получение информации о диске
USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
USED=$(df -h / | awk 'NR==2{print $3}')
TOTAL=$(df -h / | awk 'NR==2{print $2}')
FREE=$(df -h / | awk 'NR==2{print $4}' | sed 's/G//g')

# Проверка наличия свободного места на диске
if (( $(echo "$FREE < 1.0" | bc -l) )); then
    # Отображение уведомления об ошибке
    notify-send "Disk usage" "Not enough free space on disk: $FREE GB"
    # Запись ошибки в файл журнала
    echo "$(date) [ERROR] Not enough free space on disk: $FREE GB on $(hostname)" | sudo tee -a $LOG_FILE
else
    # Проверка использования диска
    if [ $USAGE -gt 80 ]; then
        # Создание изображения с информацией о диске
        convert -size 200x100 xc:white -fill black -pointsize 18 -draw "text 10,30 'Disk usage:' text 10,60 '$USAGE% ($USED of $TOTAL)'" disk_usage.png
        # Отображение уведомления с изображением
        notify-send -i disk_usage.png "Disk usage warning" "Disk usage exceeds 80%: $USAGE% ($USED of $TOTAL)"
        # Запись предупреждения в файл журнала
        echo "$(date) [WARNING] Disk usage exceeds 80%: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
    else
        # Запись сообщения в файл журнала
        echo "$(date) [INFO] Disk usage is within normal range: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
        # Отображение уведомления без изображения
        notify-send "Disk usage" "Disk usage is within normal range: $USAGE% ($USED of $TOTAL)"
    fi
fi
