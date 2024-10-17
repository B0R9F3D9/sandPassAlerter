@echo off
setlocal

rem Проверка установленных зависимостей
:check_dependencies
    rem Установленные зависимости
    for /f "delims=" %%i in ('pip freeze') do (
        echo %%i >> installed.txt
    )

    rem Сравнение с requirements.txt
    findstr /v /g:installed.txt requirements.txt > missing.txt

    if %ERRORLEVEL% neq 0 (
        echo Некоторые зависимости отсутствуют или имеют неправильные версии:
        type missing.txt
        del installed.txt missing.txt
        exit /b 1
    )

    del installed.txt missing.txt
    exit /b 0

rem Проверка установки Python 3.10 или выше
where python > nul 2> nul
if %ERRORLEVEL% neq 0 (
    echo Python не установлен. Пожалуйста, установите Python 3.10 или выше.
    exit /b 1
)

for /f "tokens=2 delims= " %%v in ('python --version') do set PYTHON_VERSION=%%v
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR_VERSION=%%a
    set MINOR_VERSION=%%b
)

if %MAJOR_VERSION% lss 3 (
    echo Установите Python версии 3.10 или выше.
    exit /b 1
) else if %MAJOR_VERSION%==3 if %MINOR_VERSION% lss 10 (
    echo Установите Python версии 3.10 или выше.
    exit /b 1
)

rem Проверка существования виртуального окружения
if not exist ".venv" (
    echo Установка зависимостей...
    python -m venv .venv
    call .venv\Scripts\activate
    pip install -r requirements.txt > nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Ошибка при установке зависимостей.
        exit /b 1
    )
) else (
    rem Активация виртуального окружения
    call .venv\Scripts\activate
)

rem Проверка зависимостей
call :check_dependencies
if %ERRORLEVEL% neq 0 (
    echo Устанавливаем отсутствующие зависимости...
    pip install -r requirements.txt > nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Ошибка при установке зависимостей.
        exit /b 1
    )
)

rem Выбор запускаемого файла
:menu
echo Выберите, что запустить:
echo 1. Notifier
echo 2. Spammer
set /p choice="Введите номер (1 или 2): "

if %choice%==1 (
    echo Запуск notifier...
    python notifier.py
) else if %choice%==2 (
    echo Запуск spammer...
    python spammer.py
) else (
    echo Неверный выбор. Пожалуйста, попробуйте снова.
    goto menu
)
