function Get-TmdbPerson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PersonId
  )
  $client = [tmdbclient]::new()
  return $client.getperson($PersonId)
}