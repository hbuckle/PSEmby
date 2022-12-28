function Get-EmbyPerson {
  [CmdletBinding(DefaultParameterSetName = 'List')]
  param (
    [ValidateNotNullOrEmpty()]
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [Parameter(ParameterSetName = 'List')]
    [string]$Server = 'https://emby.crucible.org.uk',

    [ValidateNotNullOrEmpty()]
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [Parameter(ParameterSetName = 'List')]
    [string]$ApiKey = $Script:emby_api_key,

    [Parameter(ParameterSetName = 'Name')]
    [string]$Name,

    [Parameter(ParameterSetName = 'Id')]
    [string]$Id
  )
  $builder = [System.UriBuilder]::new($Server)
  if ($PSCmdlet.ParameterSetName -eq 'Name') {
    $builder.Path = 'emby/Search/Hints'
    $builder.Query = "api_key=${ApiKey}&SearchTerm=${Name}&IncludePeople=true&IncludeItemTypes=Person"
    $response = Invoke-RestMethod $builder.ToString() -Method 'Get' -ContentType 'application/json'
    $response.SearchHints | Write-Output
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'Id') {
    $builder.Path = "Users/${ApiKey}/Items/${Id}"
    $builder.Query = "api_key=${ApiKey}"
    Invoke-RestMethod $builder.ToString() -Method 'Get' -ContentType 'application/json'
  }
  else {
    $builder.Path = 'Persons'
    $builder.Query = "api_key=${ApiKey}"
    $response = Invoke-RestMethod $builder.ToString() -Method 'Get' -ContentType 'application/json'
    $response.Items | Write-Output
  }
}
