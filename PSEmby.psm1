$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
if (-not(Test-Path "$PSScriptRoot\paths.json")) {
  throw "paths.json not present"
}
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Get-ChildItem $PSScriptRoot -Recurse -Include "*.ps1" | ForEach-Object {
  . $($_.FullName)
}
Get-ChildItem "$PSScriptRoot\Classes" -Recurse -Include "*.cs" | ForEach-Object {
  Add-Type -Path $_.FullName
}
$functions = Get-ChildItem function:\ | Where-Object { $_.Source -eq "PSEmby" } | ForEach-Object {
  $_.Name
}
Update-Metadata -Path "$PSScriptRoot\PSEmby.psd1" -PropertyName "FunctionsToExport" -Value $functions
(Get-Content "$PSScriptRoot\PSEmby.psd1" -Raw) -replace "','", "',`r`n    '" |
Set-Content "$PSScriptRoot\PSEmby.psd1" -Encoding utf8NoBOM
(Get-Content "$PSScriptRoot\PSEmby.psd1" -Raw).Replace("@('", "`@(`r`n    '") |
Set-Content "$PSScriptRoot\PSEmby.psd1" -Encoding utf8NoBOM
(Get-Content "$PSScriptRoot\PSEmby.psd1" -Raw).Replace("')", "'`r`n  )") |
Set-Content "$PSScriptRoot\PSEmby.psd1" -Encoding utf8NoBOM
$content = Get-Content "$PSScriptRoot\PSEmby.psd1" |
Where-Object { $_.Trim() -ne "" }
$content | Set-Content "$PSScriptRoot\PSEmby.psd1" -Encoding utf8NoBOM