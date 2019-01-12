function Import-TvShowJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Folder
  )
  do {
    if (Test-Path "$Folder\tvshow.json") {
      return Get-Content "$Folder\tvshow.json" -Raw | ConvertFrom-Json -AsHashtable
    }
    $Folder = Split-Path $Folder
  } while (Test-Path $Folder)
}