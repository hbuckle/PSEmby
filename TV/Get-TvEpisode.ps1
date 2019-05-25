function Get-TvEpisode {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$ShowId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$EpisodeNumber
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  return $client.gettvepisode($ShowId, $SeasonNumber, $EpisodeNumber)
}