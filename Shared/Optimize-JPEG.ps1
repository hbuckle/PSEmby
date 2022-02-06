function Optimize-JPEG {
  [CmdletBinding()]
  param (
    [string]$SourceFolder
  )
  Push-Location $SourceFolder
  & irfanview --% *.jpg /jpg_rotate=(0,1,0,0,0,0,1,0)
  Pop-Location
  Get-ChildItem $SourceFolder -Directory -Recurse | ForEach-Object {
    Push-Location $_.FullName
    & irfanview --% *.jpg /jpg_rotate=(0,1,0,0,0,0,1,0)
    Pop-Location
  }
}
