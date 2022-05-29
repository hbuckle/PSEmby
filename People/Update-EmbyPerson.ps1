function Update-EmbyPerson {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = 'https://emby.crucible.org.uk',
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [int[]]$Id
  )
  if (!$PSBoundParameters.ContainsKey('Id')) {
    $Id = Get-EmbyPeople -Server $Server -ApiKey $ApiKey | Select-Object -ExpandProperty 'Id'
  }
  $count = 1
  foreach ($item in $Id) {
    Write-Progress -Activity 'Updating people' -CurrentOperation $item -PercentComplete ($count / $Id.Count * 100)
    $null = Invoke-WebRequest "${Server}/Users/${ApiKey}/Items/${item}?api_key=${ApiKey}"
    $null = Invoke-WebRequest "${Server}/emby/Items/${item}/Refresh?Recursive=true&ImageRefreshMode=FullRefresh&MetadataRefreshMode=FullRefresh&ReplaceAllImages=true&ReplaceAllMetadata=true&api_key=${ApiKey}" -Method Post
    $count++
  }
  Write-Progress -Activity 'Updating people' -Completed
}
