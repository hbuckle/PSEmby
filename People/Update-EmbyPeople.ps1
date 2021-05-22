function Update-EmbyPeople {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key
  )
  $persons = Get-EmbyPeople -Server $Server -ApiKey $ApiKey
  $count = 1
  foreach ($person in $persons) {
    Write-Progress -Activity "Updating people" -CurrentOperation $person["Name"] -PercentComplete ($count / $persons.Count * 100)
    $null = Invoke-WebRequest "${Server}/Users/${ApiKey}/Items/$($person.Id)?api_key=${ApiKey}"
    $count++
  }
  Write-Progress -Activity "Updating people" -Completed
}
