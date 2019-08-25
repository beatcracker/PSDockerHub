# Stop on all errors
$ErrorActionPreference = 'Stop'

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module PSDeploy, BuildHelpers, Psake, Pester, PSScriptAnalyzer -Force -SkipPublisherCheck
Import-Module Psake, BuildHelpers

Set-BuildEnvironment

Invoke-psake .\psake.ps1
exit ( [int]( -not $psake.build_success ) )
