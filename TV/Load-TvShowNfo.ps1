function Load-TvShowNfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Folder
  )
  do {
    if (Test-Path "$Folder\tvshow.nfo") {
      return [embymetadata.tvshow]::Load("$Folder\tvshow.nfo")
    }
    $Folder = Split-Path $Folder
  } while (Test-Path $Folder)
}