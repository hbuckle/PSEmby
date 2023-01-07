function Invoke-Emby {
  [CmdletBinding()]
  param (
    [string]$Path,
    [hashtable]$Query = @{},
    [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
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
  $response = Invoke-RestMethod $builder.ToString() -Method $Method
  $response | Write-Output
}
