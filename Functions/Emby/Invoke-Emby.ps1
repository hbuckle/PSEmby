function Invoke-Emby {
  [CmdletBinding()]
  param (
    [string]$Path,
    [hashtable]$Query = @{},
    [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
    [object]$Body,
    [switch]$User
  )
  $builder = [System.UriBuilder]::new($Script:emby_server)
  if ($User.ToBool()) {
    $Path = "Users/${Script:emby_api_key}/${Path}"
  }
  $builder.Path = $Path.Replace('//', '/').TrimEnd('/')
  $queryStrings = @(
    "api_key=${Script:emby_api_key}"
  )
  $Query.GetEnumerator() | ForEach-Object {
    $queryStrings += "$($_.Key)=$($_.Value)"
  }
  $builder.Query = $queryStrings -join '&'
  if ($PSBoundParameters.ContainsKey('Body')) {
    $json = ConvertTo-Json -InputObject $Body -Compress -Depth 99
    $response = Invoke-RestMethod $builder.ToString() -Method $Method -Body $json -ContentType 'application/json'
  }
  else {
    $response = Invoke-RestMethod $builder.ToString() -Method $Method
  }
  $response | Write-Output
}
