#!/bin/bash

# Путь к файлу журнала
LOG_FILE="/var/log/disk_monitoring.log"

# Получение информации о диске
USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')

# Проверка использования диска
if [ $USAGE -gt 80 ]; then
    # Запись предупреждения в файл журнала
    echo "Внимание! Использование диска превышает 80%: $USAGE%" | tee -a $LOG_FILE
else
    # Запись сообщения в файл журнала
    echo "Уровень использования диска в пределах нормы: $USAGE%" | tee -a $LOG_FILE
fi
