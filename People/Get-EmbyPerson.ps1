function Get-EmbyPerson {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Id
  )
  $builder = [System.UriBuilder]::new($Server)
  $builder.Path = "Users/${ApiKey}/Items/${Id}"
  $builder.Query = "api_key=$ApiKey"
  Invoke-RestMethod $builder.ToString() -Method "Get" -ContentType "application/json" |
  ConvertTo-Json | ConvertFrom-Json -AsHashtable
}