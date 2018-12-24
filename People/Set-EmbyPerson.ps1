function Set-EmbyPerson {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [object]$Data
  )
  $builder = [System.UriBuilder]::new($Server)
  $builder.Path = "Items/${Id}"
  $builder.Query = "api_key=$ApiKey"
  Invoke-RestMethod $builder.ToString() -Method "Post" -ContentType "application/json" -Body $Data
}