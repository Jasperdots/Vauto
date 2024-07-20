@echo off

REM Check if the installation log file exists
if exist "C:\installV2.log" (
    echo Installation already completed.
    exit /b 0
)

REM Install OpenSSH server
powershell.exe -command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
powershell.exe -command "start-service sshd"
powershell.exe -command "set-service -name sshd -startuptype 'automatic'"
powershell.exe -command "New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22"
powershell.exe -command "get-service -name sshd"
powershell.exe -command "netstat -an | findstr :22"

mkdir C:\Users\Administrator\Desktop\test

REM Download PSTools using wget
powershell.exe -command "Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'C:\Users\Administrator\Desktop\test\PSTools.zip'"

REM Extract the archive
powershell.exe -command "Expand-Archive -Path 'C:\Users\Administrator\Desktop\test\PSTools.zip' -DestinationPath 'C:\Windows\System32\PStools\'"

REM Add the extracted directory to PATH
setx PATH "%PATH%;C:\Windows\System32\PStools;C:\Windows\System32\OpenSSH" /M

C:\Windows\System32\PStools\psexec -accepteula

del /f C:\Users\Administrator\Desktop\test
rmdir C:\Users\Administrator\Desktop\test 
del C:\Users\Administrator\Desktop\setup.bat
rd /s /q C:\$Recycle.Bin

ECHO Downloading Python Installer

REM Define the URL for the latest Python installer
SET PYTHON_URL=https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe

REM Define the output path
SET OUTPUT_PATH=%USERPROFILE%\Downloads\python-installer.exe

REM Download Python installer using wget
IF NOT EXIST %USERPROFILE%\Downloads\ (
    mkdir %USERPROFILE%\Downloads
)

ECHO Fetching Python installer from %PYTHON_URL%
powershell.exe -command "Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%OUTPUT_PATH%'"

ECHO Installing Python silently
%OUTPUT_PATH% /quiet InstallAllUsers=1 PrependPath=1

REM Clean up the installer
DEL %OUTPUT_PATH%

REM Verify Python installation
ECHO Verifying Python installation
python --version
IF %ERRORLEVEL% EQU 0 (
    ECHO Python has been successfully added to PATH
) ELSE (
    ECHO Python installation or PATH addition failed
)


:: Variables
set INSTALLER_URL=https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.1/Git-2.39.0-64-bit.exe
set FILENAME=GitInstaller.exe

:: Download Git Installer
echo Downloading Git...
powershell -command "Invoke-WebRequest '%INSTALLER_URL%' -OutFile '%FILENAME%'"

:: Install Git silently
echo Installing Git...
start /wait %FILENAME% /VERYSILENT /NORESTART

:: Clean up installation file
echo Cleaning up...
del /f /q %FILENAME%

REM Create an installation log file
echo Installation completed on %date% at %time% > "C:\installV2.log"

shutdown /f /r /t 0
