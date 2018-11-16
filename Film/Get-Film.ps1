function Get-Film {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ID
  )
  $client = [tmdbclient]::new()
  return $client.getfilm($ID)
}