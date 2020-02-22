function Import-SeriesJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Folder
  )
  do {
    if (Test-Path "$Folder\tvshow.json") {
      return (Read-SeriesJson -Path "$Folder\tvshow.json")
    }
    $Folder = Split-Path $Folder
  } while (Test-Path $Folder)
}