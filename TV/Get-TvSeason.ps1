function Get-TvSeason {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [int]$ShowId,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  return $client.gettvseason($ShowId, $SeasonNumber)
}