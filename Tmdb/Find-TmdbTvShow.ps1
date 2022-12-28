function Find-TmdbTvShow {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [switch]$Full
  )
  $response = Invoke-Tmdb -Path '/search/tv' -Query @{query = $Title}
  $selection = $response.results | Select-Object name, first_air_date, overview, id |
    Out-ConsoleGridView -OutputMode Single
  if ($Full.ToBool()) {
    Get-TmdbTvShow -Id $selection.id
  }
  else {
    Write-Output $selection
  }
}
