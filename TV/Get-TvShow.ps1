function Get-TvShow {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [int]$ShowId
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  return $client.gettvshow($ShowId)
}