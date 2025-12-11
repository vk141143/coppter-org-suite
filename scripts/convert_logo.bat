@echo off
echo Converting logo to web icons...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Check if PIL (Pillow) is installed
python -c "import PIL" >nul 2>&1
if errorlevel 1 (
    echo Installing Pillow (PIL) for image processing...
    pip install Pillow
)

REM Run the conversion script
python convert_logo.py

echo.
echo Press any key to continue...
pause >nul