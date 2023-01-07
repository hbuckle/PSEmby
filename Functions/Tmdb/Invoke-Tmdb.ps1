function Invoke-Tmdb {
  [CmdletBinding()]
  param (
    [string]$Path,
    [hashtable]$Query = @{},
    [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get'
  )
  $builder = [System.UriBuilder]::new('https://api.themoviedb.org')
  $builder.Path = "3/${path}".Replace('//', '/').TrimEnd('/')
  $queryStrings = @(
    "api_key=${Script:tmdb_api_key}"
  )
  $Query.GetEnumerator() | ForEach-Object {
    $queryStrings += "$($_.Key)=$($_.Value)"
  }
  $builder.Query = $queryStrings -join '&'
  $response = Invoke-RestMethod $builder.ToString() -Method $Method -RetryIntervalSec 10 -MaximumRetryCount 3
  $response | Write-Output
}
