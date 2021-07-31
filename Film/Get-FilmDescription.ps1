function Get-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $searchterm = [System.Uri]::EscapeUriString($Title)
  $listings = Invoke-RestMethod "https://search.api.immediate.co.uk/v4/search?sitekey=radiotimes&search=${searchterm}&tab=programmes-films"
  $films = $listings.data.results | Where-Object {
    $_.categories.name -eq "Film"
  }
  $film = Select-ItemFromList -List $films -Properties @("title", "description")
  if ($null -eq $film) {
    return New-Object -TypeName "PSObject" -Property @{ title = ""; review = "" }
  }
  $filmuri = "https://www.radiotimes.com$($film.url)"
  $parser = [AngleSharp.Html.Parser.HtmlParser]::new()
  $reviewpage = Invoke-RestMethod $filmuri
  $reviewdocument = $parser.ParseDocument($reviewpage)
  $search = @()
  $object = @{ review = "" }
  $object["title"] = $reviewdocument.GetElementsByClassName("post-header__title post-header__title--masthead-layout heading-2").TextContent.Trim()
  $object["review"] = $reviewdocument.GetElementById('show-review-review-region').GetElementsByClassName('editor-content').TextContent.Trim()
  $search += New-Object -TypeName "PSObject" -Property $object
  $selected = Select-ItemFromList -List $search -Properties @("title", "review")
  if ($null -eq $selected) {
    return New-Object -TypeName "PSObject" -Property @{title = ""; review = "" }
  }
  else {
    return $selected
  }
  catch {
    Write-Warning $_.Exception.Message
  }
}
