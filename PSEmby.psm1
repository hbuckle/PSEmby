$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
if (-not(Test-Path "$PSScriptRoot\paths.json")) {
  throw "paths.json not present"
}
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Get-ChildItem $PSScriptRoot -Recurse -Include "*.ps1" | ForEach-Object { . $($_.FullName) }
Get-ChildItem "$PSScriptRoot\Classes" | ForEach-Object {
  Add-Type -Path $_.FullName
}