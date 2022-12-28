function Import-SeriesJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonSeries])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputFolder
  )
  do {
    $output = Join-Path $InputFolder 'tvshow.json'
    if (Test-Path $output) {
      return (Read-SeriesJson -Path $output)
    }
    $InputFolder = Split-Path $InputFolder
  } while (Test-Path $InputFolder)
}
