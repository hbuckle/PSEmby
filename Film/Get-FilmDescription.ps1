function Get-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $baseuri = "https://www.radiotimes.com"
  $uri = [System.Uri]::EscapeUriString("${baseuri}/search/programmes-films/?q=${Title}")
  try {
    $search = @()
    $parser = [AngleSharp.Parser.Html.HtmlParser]::new()
    $searchresult = Invoke-RestMethod $uri
    $searchdocument = $parser.Parse($searchresult)
    $links = $searchdocument.Links.Where({$_.PathName.StartsWith("/film/")})
    foreach ($link in $links) {
      if ($link.PathName -ne "/film/") {
        $reviewpage = Invoke-RestMethod "${baseuri}$($link.PathName)"
        $reviewdocument = $parser.Parse($reviewpage)
        foreach ($review in $reviewdocument.GetElementsByClassName("episode-extra__copy")) {
          if (@($review.Attributes.Where({$_.Value -eq "reviewBody"})).Count -gt 0) {
            $search += $review.TextContent.Trim()
          }
        }
      }
    }
    $result = @()
    $result += $search | Select-Object -Unique
    $selected = Select-ItemFromList -List $result
    if ($null -eq $selected) {
      return ""
    }
    else {
      return $selected
    }
  }
  catch {
    Write-Warning "${baseuri}$($link.PathName)"
    Write-Warning $_.Exception.Message
  }
}