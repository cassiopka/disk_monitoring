#!/bin/bash

# Обработка аргументов командной строки
while getopts "t:l:" opt; do
  case $opt in
    t)
      THRESHOLD="$OPTARG"
      ;;
    l)
      LOG_FILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Проверка, установлено ли пороговое значение
if [ -z "$THRESHOLD" ]; then
  THRESHOLD=80
fi

# Проверка, указан ли путь к файлу журнала
if [ -z "$LOG_FILE" ]; then
  LOG_FILE="/var/log/disk_monitoring.log"
fi

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
    if [ $USAGE -gt $THRESHOLD ]; then
        # Создание изображения с информацией о диске
        convert -size 200x100 xc:white -fill black -pointsize 18 -draw "text 10,30 'Disk usage:' text 10,60 '$USAGE% ($USED of $TOTAL)'" disk_usage.png
        # Отображение уведомления с изображением
        notify-send -i disk_usage.png "Disk usage warning" "Disk usage exceeds $THRESHOLD%: $USAGE% ($USED of $TOTAL)"
        # Запись предупреждения в файл журнала
        echo "$(date) [WARNING] Disk usage exceeds $THRESHOLD%: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
    else
        # Запись сообщения в файл журнала
        echo "$(date) [INFO] Disk usage is within normal range: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
        # Отображение уведомления без изображения
        notify-send "Disk usage" "Disk usage is within normal range: $USAGE% ($USED of $TOTAL)"
    fi
fi
