break

Install-Module PowerShellGet -Force
Import-Module PowerShellGet -Force

$Module = Split-Path -Path $PWD -Leaf
$Repository = 'UNIBAS'

if (-not $env:NuGetApiKey)
{
    if (Test-Path .\Api.key)
    {
        $env:NuGetApiKey = Get-Content -Path .\Api.key | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    }
    else
    {
        $env:NuGetApiKey = Read-Host -Prompt "Enter your API Key" -AsSecureString | ConvertFrom-SecureString
    }
}

# Register Repository
$paramRegisterPSRepository = @{
    Name                      = $Repository
    SourceLocation            = 'http://its-psrepository.its.unibas.ch/nuget/UNIBAS/'
    PublishLocation           = 'http://its-psrepository.its.unibas.ch/nuget/UNIBAS/'
    InstallationPolicy        = 'Trusted'
    PackageManagementProvider = 'NuGet'
}
Unregister-PSRepository -Name $paramRegisterPSRepository.Name
Register-PSRepository @paramRegisterPSRepository

# Publish Module
$paramPublishModule = @{
    Path        = ".\$Module"
    NuGetApiKey = ([PSCredential]::new('User', (ConvertTo-SecureString -String $env:NuGetApiKey))).GetNetworkCredential().Password
    Repository  = $Repository
    Force       = $true
    Verbose     = $true
    ErrorAction = 'Stop'
}

Write-Host "Publishing Module '$Module' to Repository '$Repository'"

Publish-Module @paramPublishModule
