function Get-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $filmuri = "https://www.radiotimes.com"
  $searchterm = [System.Uri]::EscapeUriString("site:${filmuri}/film `"${Title}`"")
  $searchuri = "https://api.cognitive.microsoft.com/bing/v7.0/search?q=${searchterm}"
  $headers = @{"Ocp-Apim-Subscription-Key" = $Script:bing_api_key }
  $search = @()
  try {
    $parser = [AngleSharp.Parser.Html.HtmlParser]::new()
    $searchresult = Invoke-RestMethod $searchuri -Headers $headers
    $links = @()
    if ($null -ne (Get-Member -InputObject $searchresult -Name "webPages")) {
      foreach ($page in $searchresult.webPages.value) {
        $links += $page.url
      }
    }
    foreach ($link in $links) {
      if ($link -eq "https://www.radiotimes.com/film/") {
        continue
      }
      $reviewpage = Invoke-RestMethod $link
      $reviewdocument = $parser.Parse($reviewpage)
      $object = @{ }
      $object["title"] = $reviewdocument.GetElementsByClassName("programme-header__heading  js-programme-page-header").TextContent.Trim()
      foreach ($review in $reviewdocument.GetElementsByClassName("episode-extra__copy")) {
        if (@($review.Attributes.Where( { $_.Value -eq "reviewBody" })).Count -gt 0) {
          $object["review"] = $review.TextContent.Trim()
          $search += New-Object -TypeName "PSObject" -Property $object
        }
      }
    }
    $selected = Select-ItemFromList -List $search -Properties @("title", "review")
    if ($null -eq $selected) {
      return New-Object -TypeName "PSObject" -Property @{title = ""; review = "" }
    }
    else {
      return $selected
    }
  }
  catch {
    Write-Warning $_.Exception.Message
  }
}