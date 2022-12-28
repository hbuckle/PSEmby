function Find-TmdbFilm {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [switch]$Full
  )
  $response = Invoke-Tmdb -Path '/search/movie' -Query @{query = $Title}
  $selection = $response.results | Select-Object title, release_date, overview, id |
    Out-ConsoleGridView -OutputMode Single
  if ($Full.ToBool()) {
    Get-TmdbFilm -Id $selection.id
  }
  else {
    Write-Output $selection
  }
}
