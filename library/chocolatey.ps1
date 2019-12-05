function Get-ChocolateyPath {
    return $env:Path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object $item | Where-Object { $_ -like "*choco*" }
}

function Test-Chocolatey {
    $chocoPath = Get-ChocolateyPath
    return $null -eq $chocoPath
}

function Install-Chocolatey {
    Write-Host "Installing Chocolatey..."

    $url = "https://chocolatey.org/install.ps1"
    $file = "$env:temp\chocolatey.ps1"

    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    &$file | Out-Null

    Remove-Item -Path $file | Out-Null
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Update-Chocolatey {
    Write-Host "Updating Chocolatey..."

    $chocoPath = Get-ChocolateyPath
    Start-Process -FilePath "$chocoPath\choco.exe" -ArgumentList "upgrade chocolatey -y" -Wait -NoNewWindow
}