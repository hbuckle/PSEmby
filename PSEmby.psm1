$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
Set-StrictMode -Version Latest

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
