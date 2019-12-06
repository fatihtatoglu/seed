function Initialize-Seed {
    ########################################
    ############## Chocolatey ##############
    ########################################
    function Get-ChocolateyPath {
        return $env:Path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object $item | Where-Object { $_ -like "*choco*" }
    }

    function Test-Chocolatey {
        $chocoPath = Get-ChocolateyPath
        return $null -ne $chocoPath
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

    function Install-ChocolateyModule {
        param (
            [string[]]$Modules
        )
        
        $chocoPath = Get-ChocolateyPath
        $modulesLine = [string]$Modules
        Start-Process -FilePath "$chocoPath\choco.exe" -ArgumentList "install $modulesLine -y" -Wait -NoNewWindow | Out-Null
    
        Write-Host "Following modules is installed. Modules: $modulesLine"
    }

    ########################################
    ############### Windows ################
    ########################################
    function Remove-Folder {
        param(
            [Parameter(Mandatory = $true)][string]$Path
        )
                
        Get-ChildItem $Path -Recurse | Remove-Item -Recurse -Confirm:$false -Force
        Remove-Item -Force -Recurse -Path "$Path\*" -Confirm:$false
    }

    ########################################
    ################# Git ##################
    ########################################
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

    function Get-GitPath {
        return $env:Path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object $item | Where-Object { $_ -like "*\git\*" }
    }

    ########################################
    ################ Main ##################
    ########################################
    [string]$workspacePath = $(Read-Host "Workspace Path")
    
    $isInstalled = Test-Chocolatey;
    if ($false -eq $isInstalled) {
        Install-Chocolatey
    }

    $isGitInstalled = Test-Git
    if ($false -eq $isGitInstalled) {
        Install-ChocolateyModule -Modules "git"
    }

    $isExist = Test-Path -Path  $workspacePath
    if ($false -eq $isExist) {
        New-Item -Path $workspacePath -ItemType Directory -Force | Out-Null
    }

    Import-GitRepository -RepositoryUrl "https://github.com/fatihtatoglu/seed.git" -LocalRepositoryPath  $workspacePath
    Set-Location "$workspacePath\seed"
}

Initialize-Seed

Write-Host "Seed initialized."
Write-Host "Now prepare environment config file. The example is 'example.xml' file."
Write-Host "Then execute germinate.ps1 for germinating of seed in config file."