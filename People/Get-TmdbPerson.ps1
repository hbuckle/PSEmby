function Get-TmdbPerson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PersonId
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  return $client.getperson($PersonId)
}