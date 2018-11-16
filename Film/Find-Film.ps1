function Find-Film {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $client = [tmdbclient]::new($Script:api_key)
  $search = $client.searchfilm($Title)
  $film = Select-ItemFromList -List $search -Properties @("title", "release_date", "overview")
  if ($null -eq $film) {
    throw "$Title not found"
  }
  else {
    return $film
  }
}