#!/bin/bash

# Путь к файлу журнала
LOG_FILE="/var/log/disk_monitoring.log"

# Получение информации о диске
USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
USED=$(df -h / | awk 'NR==2{print $3}')
TOTAL=$(df -h / | awk 'NR==2{print $2}')

# Проверка использования диска
if [ $USAGE -gt 80 ]; then
    # Запись предупреждения в файл журнала
    echo "$(date) [WARNING] Disk usage exceeds 80%: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
    # Отправка уведомления по электронной почте
    echo "Disk usage warning on $(hostname): $USAGE% ($USED of $TOTAL)" | mail -s "Disk usage warning" user@example.com
else
    # Запись сообщения в файл журнала
    echo "$(date) [INFO] Disk usage is within normal range: $USAGE% ($USED of $TOTAL) on $(hostname)" | sudo tee -a $LOG_FILE
fi
