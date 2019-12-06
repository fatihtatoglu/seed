. "library\windows.ps1"

function Get-GitPath {
    return $env:Path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object $item | Where-Object { $_ -like "*\git\*" }
}

function Test-Git {
    $gitPath = Get-GitPath
    return $null -ne $gitPath
}

function Import-GitRepository {
    param (
        [Parameter(Mandatory = $true)][string]$RepositoryUrl,
        [Parameter(Mandatory = $true)][string]$LocalRepositoryPath
    )
    
    $currentLocation = Get-Location
    $gitPath = Get-GitPath
    $repositoryName = $RepositoryUrl.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Last 1
    $repositoryName = $repositoryName.Replace(".git", "")

    Set-Location -Path $LocalRepositoryPath
    $reposityPath = "$LocalRepositoryPath\$repositoryName"
    $isExist = (Test-Path -Path $reposityPath) -or (Test-Path -Path "$reposityPath\.git")
    if ($true -eq $isExist) {
        $canRemove = Read-Host "'$repositoryName' folder is already exists. Remove folder [Y]es [N]o"
        switch ($canRemove.ToLower()) { 
            { ($_ -eq "y") -or ($_ -eq "yes") } { 
                
                $date = [datetime]::Now
                $archivePath = "{0}\backup_{1}_{2:yyyyMMddHHmmss}.zip" -f $LocalRepositoryPath, $repositoryName, $date;
                
                Add-Type -AssemblyName "system.io.compression.filesystem";
                [io.compression.zipfile]::CreateFromDirectory($reposityPath, $archivePath);

                Remove-Folder -Path $reposityPath | Out-Null

                Write-Host "'$repositoryName' folder is removed. But folder content is compressed in '$LocalRepositoryPath' with $archivePath file. ;)"
            } 
            default {  
                Set-Location -Path $currentLocation
                Write-Host "Operation is cancelled."
                return
            } 
        }
    }

    Start-Process -FilePath "$gitPath\git.exe" -ArgumentList "clone $RepositoryUrl" -Wait -NoNewWindow | Out-Null

    Write-Host "Repository '$repositoryName' is imported."
    Set-Location -Path $currentLocation
}