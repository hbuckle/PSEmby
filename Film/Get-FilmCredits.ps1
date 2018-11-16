function Get-FilmCredits {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ID
  )
  $client = [tmdbclient]::new($Script:api_key)
  return $client.getfilmcredits($ID)
}