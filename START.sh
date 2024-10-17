#!/bin/bash

check_dependencies() {
    # Установленные зависимости
    INSTALLED=$(pip3 freeze)

    # Сравнение с requirements.txt
    MISSING=$(comm -13 <(echo "$INSTALLED" | sort) <(sort requirements.txt))

    if [ -n "$MISSING" ]; then
        echo "Некоторые зависимости отсутствуют или имеют неправильные версии:"
        echo "$MISSING"
        return 1
    fi

    return 0
}

if ! command -v python3 &> /dev/null; then
    echo "Python не установлен. Пожалуйста, установите Python 3.10 или выше."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
MAJOR_VERSION=$(echo "$PYTHON_VERSION" | cut -d '.' -f 1)
MINOR_VERSION=$(echo "$PYTHON_VERSION" | cut -d '.' -f 2)

if [ "$MAJOR_VERSION" -lt 3 ] || { [ "$MAJOR_VERSION" -eq 3 ] && [ "$MINOR_VERSION" -lt 10 ]; }; then
    echo "Установите Python версии 3.10 или выше."
    exit 1
fi

if [ ! -d ".venv" ]; then
    echo "Установка зависимостей..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip3 install -r requirements.txt > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Ошибка при установке зависимостей."
        exit 1
    fi
else
    # Активация виртуального окружения
    source .venv/bin/activate
fi

check_dependencies
if [ $? -ne 0 ]; then
    echo "Устанавливаем отсутствующие зависимости..."
    pip3 install -r requirements.txt > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Ошибка при установке зависимостей."
        exit 1
    fi
fi

while true; do
    echo "Выберите, что запустить:"
    echo "1. Notifier"
    echo "2. Spammer"
    read -p "Введите номер (1 или 2): " choice

    if [ "$choice" -eq 1 ]; then
        echo "Запуск notifier..."
        python3 notifier.py
        break
    elif [ "$choice" -eq 2 ]; then
        echo "Запуск spammer..."
        python3 spammer.py
        break
    else
        echo "Неверный выбор. Пожалуйста, попробуйте снова."
    fi
done
