function Find-EmbyItem {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = "https://emby.crucible.org.uk",
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Name
  )
  $builder = [System.UriBuilder]::new($Server)
  $builder.Path = "Users/${ApiKey}/Items"
  $builder.Query = "api_key=$ApiKey&NameStartsWith=${Name}&Recursive=true&Fields=People,Genres"
  $response = Invoke-RestMethod $builder.ToString() -Method "Get" -ContentType "application/json" |
  ConvertTo-Json | ConvertFrom-Json -AsHashtable
  return $response["Items"]
}