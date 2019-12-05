function Disable-UserAccessControl {
    Write-Host "Disabling User Access Control (UAC)..."

    New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force
}

function Set-FolderOption {
    Write-Host "Setting folder option..."

    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Set-ItemProperty . Hidden "1"
    Pop-Location
}

function Get-OsDriveLetter {
    return (Get-WmiObject Win32_OperatingSystem).SystemDrive
}