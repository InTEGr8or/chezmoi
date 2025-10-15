# Import custom modules
$modulePath = Join-Path $PSScriptRoot "Modules"
$env:PSModulePath = $env:PSModulePath + [System.IO.Path]::PathSeparator + $modulePath

# Import handex module if exists
if (Test-Path (Join-Path $modulePath "handex")) {
    Import-Module handex
}

# AWS helpers
function Set-AWSProfile {
    param([string]$ProfileName)
    $env:AWS_PROFILE = $ProfileName
    Write-Host "AWS Profile set to: $ProfileName"
}

# Add other customizations here
