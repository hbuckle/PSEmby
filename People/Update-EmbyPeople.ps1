function Update-EmbyPeople {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key
  )
  $persons = Get-EmbyPeople -Server $Server -ApiKey $ApiKey
  foreach ($person in $persons) {
    $null = Invoke-WebRequest "${Server}/Users/${ApiKey}/Items/$($person.Id)?api_key=${ApiKey}"
  }
}