# Turn off echo
$ErrorActionPreference = "SilentlyContinue"

# Check if the installation log file exists
if (Test-Path "C:\installV2.log") {
    Write-Host "Installation already completed."
    exit
}

# Install OpenSSH server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled $true -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
Get-Service -Name sshd
netstat -an | Select-String ":22"

# Create test directory
New-Item -ItemType Directory -Path "C:\Users\Administrator\Desktop\test" -Force

# Download PSTools using Invoke-WebRequest
Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'C:\Users\Administrator\Desktop\test\PSTools.zip'

# Extract the archive
Expand-Archive -Path 'C:\Users\Administrator\Desktop\test\PSTools.zip' -DestinationPath 'C:\Windows\System32\PStools'

# Add the extracted directory to PATH
$env:PATH += ";C:\Windows\System32\PStools;C:\Windows\System32\OpenSSH"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::Machine)

# Run PSTools to accept the EULA
& C:\Windows\System32\PStools\psexec -accepteula

# Cleanup test directory
Remove-Item -Path C:\Users\Administrator\Desktop\test -Recurse -Force
Remove-Item -Path C:\Users\Administrator\Desktop\setup.bat -Force
Clear-RecycleBin -Force -Confirm:$false

# Download Python Installer
$PYTHON_URL = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"
$OUTPUT_PATH = "$env:USERPROFILE\Downloads\python-installer.exe"

# Create Downloads directory if it doesn't exist
if (-not (Test-Path "$env:USERPROFILE\Downloads")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\Downloads"
}

Write-Host "Fetching Python installer from $PYTHON_URL"
Invoke-WebRequest -Uri $PYTHON_URL -OutFile $OUTPUT_PATH

# Install Python silently
Write-Host "Installing Python silently"
Start-Process -FilePath $OUTPUT_PATH -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait

# Clean up the installer
Remove-Item -Path $OUTPUT_PATH -Force

# Verify Python installation
Write-Host "Verifying Python installation"
$pythonVersion = python --version
if ($LASTEXITCODE -eq 0) {
    Write-Host "Python has been successfully added to PATH"
} else {
    Write-Host "Python installation or PATH addition failed"
}

# Download Git Installer
$INSTALLER_URL = "https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.1/Git-2.39.0-64-bit.exe"
$FILENAME = "GitInstaller.exe"

Write-Host "Downloading Git..."
Invoke-WebRequest -Uri $INSTALLER_URL -OutFile $FILENAME

# Install Git silently
Write-Host "Installing Git..."
Start-Process -FilePath $FILENAME -ArgumentList '/VERYSILENT /NORESTART' -Wait

# Clean up installation file
Write-Host "Cleaning up..."
Remove-Item -Path $FILENAME -Force

# Create an installation log file
"Installation completed on $(Get-Date)" | Out-File "C:\installV2.log"

# Restart the computer immediately
Restart-Computer -Force
