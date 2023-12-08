$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
Set-StrictMode -Version Latest
[System.Console]::InputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not(Test-Path "$PSScriptRoot\paths.json")) {
  throw 'paths.json not present'
}
. "$PSScriptRoot/Set-ToolPaths.ps1"

@(
  'AngleSharp.dll',
  'JsonMetadata.dll'
) | ForEach-Object {
  $path = Join-Path "$PSScriptRoot/lib" $_
  $bytes = Get-Content $path -AsByteStream -Raw
  [System.Reflection.Assembly]::Load($bytes)
}

Get-ChildItem "$PSScriptRoot/Functions" -Recurse -Include '*.ps1' | ForEach-Object {
  . $($_.FullName)
}

do {
  Get-ChildItem "$PSScriptRoot/Classes" -Recurse -Include '*.cs' | ForEach-Object {
    try {
      Add-Type -Path $_.FullName -ErrorVariable 'typeerror'
    }
    catch {}
  }
}
while ($typeerror.Count -gt 0)

if (-not(Test-Path "$PSScriptRoot\Tools\Scraper\bin\Release\net8.0\Scraper.exe")) {
  Push-Location "$PSScriptRoot\Tools\Scraper"
  & dotnet publish -c Release
  Pop-Location
}
Set-Alias -Name 'Scraper' -Value "$PSScriptRoot\Tools\Scraper\bin\Release\net8.0\Scraper.exe"
. "$PSScriptRoot\Tools\Scraper\bin\Release\net8.0\playwright.ps1" install
