#!/bin/bash

# Получение информации о диске
USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
USED=$(df -h / | awk 'NR==2{print $3}')
TOTAL=$(df -h / | awk 'NR==2{print $2}')

# Проверка использования диска
if [ $USAGE -gt 80 ]; then
    # Создание изображения с информацией о диске
    convert -size 200x100 xc:white -fill black -pointsize 18 -draw "text 10,30 'Disk usage:' text 10,60 '$USAGE% ($USED of $TOTAL)'" disk_usage.png
    # Отображение уведомления с изображением
    notify-send -i disk_usage.png "Disk usage warning" "Disk usage exceeds 80%: $USAGE% ($USED of $TOTAL)"
else
    # Отображение уведомления без изображения
    notify-send "Disk usage" "Disk usage is within normal range: $USAGE% ($USED of $TOTAL)"
fi
