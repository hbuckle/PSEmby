function Get-EmbyPeople {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key
  )
  $builder = [System.UriBuilder]::new($Server)
  $builder.Path = "persons"
  $builder.Query = "api_key=$ApiKey"
  $result = Invoke-RestMethod $builder.ToString() -Method "Get" -ContentType "application/json"
  foreach ($item in $result.Items) {
    $person = [EmbyPerson]$item
    Write-Output $person
  }
}