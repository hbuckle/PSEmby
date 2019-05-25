function Get-FilmRating {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $uribuilder = [System.UriBuilder]::new("https://bbfc.co.uk")
  $searchpath = [System.Uri]::EscapeUriString($Title)
  $uribuilder.Path = "/search/releases/$searchpath"
  $mapping = @{
    "BBFC_U"   = "GB-U"
    "BBFC_PG"  = "GB-PG"
    "BBFC_12A" = "GB-12A"
    "BBFC_12"  = "GB-12"
    "BBFC_15"  = "GB-15"
    "BBFC_18"  = "GB-18"
  }
  try {
    $parser = [AngleSharp.Parser.Html.HtmlParser]::new()
    $searchresult = Invoke-RestMethod $uribuilder.ToString()
    $searchpage = $parser.Parse($searchresult)
    $searchresults = $searchpage.GetElementsByClassName("search-result")
    $features = @()
    foreach ($result in $searchresults) {
      $footer = $result.GetElementsByClassName("search-snippet-footer")
      if ($footer.InnerText -notmatch "Feature") {
        continue
      }
      $features += $result
    }
    $choices = @()
    foreach ($feature in $features) {
      $choices += @{
        Title  = $feature.GetElementsByClassName("title").InnerText
        Symbol = $feature.GetElementsByClassName("symbol").FirstChild.Source
      }
    }
    $choice = Select-ItemFromList -List $choices -Properties @("Title") -Title "Rating"
    $rating = ""
    if ($null -ne $choice) {
      $uri = [System.Uri]::new($choice["Symbol"])
      $image = $uri.Segments | Select-Object -Last 1
      foreach ($key in $mapping.Keys) {
        if ($image.StartsWith($key)) {
          $rating = $mapping[$key]
          break
        }
      }
    }
    return $rating
  }
  catch {
    Write-Warning $_.Exception.Message
  }
}