. "library\chocolatey.ps1"
. "library\git.ps1"
. "library\windows.ps1"

function Import-Config {
    param (
        [string]$ConfigFilePath = $(Read-Host "Config File Path")
    )

    $isConfigExist = Test-Path -Path $ConfigFilePath
    if ($false -eq $isConfigExist) {
        Write-Host "Config file is missing."
        return
    }

    [xml]$xml = Get-Content -Path $ConfigFilePath

    Write-Host "Installing packages..."
    foreach ($package in $xml.config.packages.package) {
        $id = $package.id;
        Install-ChocolateyModule -Modules $id
    }

    [string]$workspacePath = $(Read-Host "Workspace Path")
    Write-Host "Cloning repositories..."
    foreach ($repository in $xml.config.repositories.repository) {
        $url = $repository.url;
        Import-GitRepository -RepositoryUrl $url -LocalRepositoryPath $workspacePath
    }

    Disable-UserAccessControl
    Set-FolderOption
}

Import-Config

Write-Host "Germination is completed."
Write-Host "The growing stage is started. With developing code you can grow yourself and your projects."
Write-Host "Have a nice journey in your programming life cycle."
Write-Host "Fatih Tatoğlu / fatih@tatoglu.net"
Write-Host "########################################"
Write-Host "For new features and any issues use: https://github.com/fatihtatoglu/seed/issues"