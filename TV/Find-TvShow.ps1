function Find-TvShow {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  $search = $client.searchtvshow($Title)
  $show = Select-ItemFromList -List $search -Properties @("name", "overview")
  if ($null -eq $show) {
    throw "$Title not found"
  }
  else {
    return $show
  }
}