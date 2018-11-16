$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Get-ChildItem $PSScriptRoot -Recurse -Include "*.ps1" | ForEach-Object { . $($_.FullName) }