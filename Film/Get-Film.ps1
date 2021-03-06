function Get-Film {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ID
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  return $client.getfilm($ID)
}