function Get-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [int]$MaxCount = 8
  )
  $searchterm = [System.Uri]::EscapeUriString($Title)
  $listings = Invoke-RestMethod "https://www.radiotimes.com/api/search-frontend/search?q=${searchterm}&tab=broadcast"
  $films = $listings.searchResults.items
  $scraper = Get-Alias -Name 'Scraper' | Select-Object -ExpandProperty Definition
  $choices = $films | Select-Object -First $MaxCount | ForEach-Object -Parallel {
    Set-Alias -Name 'Scraper' -Value $Using:scraper
    $filmuri = "https://www.radiotimes.com$($_.url)"
    $reviewpage = & Scraper $filmuri
    $parser = [AngleSharp.Html.Parser.HtmlParser]::new()
    $reviewdocument = $parser.ParseDocument($reviewpage)
    $review = $reviewdocument.GetElementById('show-review-review-region')?.GetElementsByClassName('editor-content')?.TextContent?.Trim()
    New-Object -TypeName psobject -Property ([ordered]@{
        Title  = $_.title
        Review = $review
      })
  } -ThrottleLimit 4
  $selection = $choices | Out-ConsoleGridView -OutputMode Single -Title 'Get-FilmDescription' -MinUI
  if ($null -eq $selection) {
    [string]::Empty | Write-Output
  }
  else {
    Write-Output $selection.Review
  }
}
