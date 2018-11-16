function Get-FilmCredits {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ID
  )
  $client = [tmdbclient]::new()
  return $client.getfilmcredits($ID)
}