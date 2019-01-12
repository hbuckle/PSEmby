function Get-EmbyPeople {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [switch]$Full
  )
  $builder = [System.UriBuilder]::new($Server)
  $builder.Path = "persons"
  $builder.Query = "api_key=$ApiKey"
  $result = Invoke-RestMethod $builder.ToString() -Method "Get" -ContentType "application/json"
  foreach ($item in $result.Items) {
    if ($Full) {
      $fullperson = Get-EmbyPerson -Server $Server -ApiKey $ApiKey -Id $item.Id
      Write-Output $fullperson
    }
    else {
      $person = $item | ConvertTo-Json | ConvertFrom-Json -AsHashtable
      Write-Output $person
    }
  }
}