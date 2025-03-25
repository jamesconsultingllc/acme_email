@echo off
SETLOCAL EnableDelayedExpansion

REM Check if Docker is installed
WHERE docker >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Docker is not installed or not in PATH. Please install Docker Desktop.
    EXIT /B 1
)

REM Create directories if they don't exist
IF NOT EXIST letsencrypt mkdir letsencrypt
IF NOT EXIST letsencrypt-lib mkdir letsencrypt-lib
IF NOT EXIST letsencrypt-log mkdir letsencrypt-log

REM Check if Docker image exists
docker images acme-email-client -q >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Building Docker image...
    docker build -t acme-email-client .
    IF %ERRORLEVEL% NEQ 0 (
        ECHO Failed to build Docker image.
        EXIT /B 1
    )
)

ECHO Running ACME Email S/MIME Client...
docker run --rm -v "%cd%\letsencrypt:/etc/letsencrypt" -v "%cd%\letsencrypt-lib:/var/lib/letsencrypt" -v "%cd%\letsencrypt-log:/var/log/letsencrypt" acme-email-client %*

ECHO Done.
ENDLOCAL 