function Get-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $searchterm = [System.Uri]::EscapeUriString($Title)
  $listings = Invoke-RestMethod "https://search.api.immediate.co.uk/v4/search?sitekey=radiotimes&search=${searchterm}&tab=programmes-films"
  $films = $listings.data.results | Where-Object {
    $_.categories.name -eq 'Film'
  }
  $film = $films | Select-Object title, description, url |
    Out-ConsoleGridView -OutputMode Single
  if ($null -eq $film) {
    [string]::Empty | Write-Output
    return
  }
  $filmuri = "https://www.radiotimes.com$($film.url)"
  $parser = [AngleSharp.Html.Parser.HtmlParser]::new()
  $reviewpage = Invoke-RestMethod $filmuri
  $reviewdocument = $parser.ParseDocument($reviewpage)
  $review = $reviewdocument.GetElementById('show-review-review-region')?.GetElementsByClassName('editor-content')?.TextContent?.Trim()
  Write-Host 'Review:'
  Write-Host
  Write-Host $review
  Write-Host
  [char]$prompt = 'x'
  while ($prompt -notin 'y', 'n') {
    $prompt = Read-Host -Prompt 'Use this review (y/n)'
  }
  if ($prompt -eq 'y') {
    Write-Output $review
  }
  else {
    [string]::Empty | Write-Output
  }
}
