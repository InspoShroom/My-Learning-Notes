@echo off
title DB Notes Server
echo ===================================================
echo   DB Notes Startup and Management Service
echo ===================================================
echo.

:: 1. Clean port 8125
echo [1/4] Checking and cleaning port 8125...
set found=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8125 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
    set found=1
)
if %found%==1 (
    echo      Successfully terminated conflicting process on port 8125.
) else (
    echo      Port 8125 is clean and free.
)
timeout /t 1 /nobreak >nul
echo.

:: 2. Activate virtual environment
echo [2/4] Activating Python virtual environment (..\.venv)...
if not exist "..\.venv\Scripts\activate.bat" goto VENV_ERROR

call ..\.venv\Scripts\activate
echo      Virtual environment activated successfully.
goto VENV_OK

:VENV_ERROR
echo [ERROR] Virtual environment directory (.venv\Scripts\activate.bat) not found!
echo         Please make sure you are running from the correct directory.
pause
exit

:VENV_OK
echo.

:: 3. Launch browser
echo [3/4] Launching default browser to open notes...
start http://127.0.0.1:8125
echo.

:: 4. Start MkDocs Server
echo [4/4] Starting MkDocs local server...
echo      -------------------------------------------------
echo      INFO: Press [Ctrl + C] in this window to stop the server.
echo            The virtual environment will be deactivated automatically.
echo      -------------------------------------------------
echo.
python -m mkdocs serve -a 127.0.0.1:8125

:: 5. Deactivate virtual environment
echo.
echo Deactivating virtual environment...
call deactivate
echo Service stopped.
timeout /t 2 /nobreak >nul
pause
