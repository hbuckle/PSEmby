function Get-BDMVIndex {
  [CmdletBinding()]
  param (
    [string]$Path
  )
  $bdmv = Get-ChildItem -Path $Path -Filter 'BDMV' -Directory | Select-Object -First 1
  if ($null -eq $bdmv) {
    throw "BDMV directory not found in $Path"
  }
  $index = Join-Path $bdmv.FullName 'index.bdmv'
  & mpls2json $index | ConvertFrom-Json -Depth 99 -NoEnumerate
}
