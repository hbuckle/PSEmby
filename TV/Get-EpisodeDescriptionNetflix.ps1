function Get-EpisodeDescriptionNetflix {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$EpisodeNumber
  )
  $uri = "https://www.netflix.com/title/${Id}"
  try {
    $parsed = (Get-Variable -Scope "Script" -Name $Id).Value
  }
  catch {
    $page = Invoke-RestMethod $uri
    $parser = [AngleSharp.Html.Parser.HtmlParser]::new()
    $parsed = $parser.ParseDocument($page)
    New-Variable -Scope "Script" -Name $Id -Value $parsed
  }
  # $seasons = $parsed.GetElementsByClassName("kitchen-sink-grid-wrapper")
  $match = "Episode ${EpisodeNumber} of Season ${SeasonNumber}"
  $img = $parsed.GetElementsByClassName("title-episode-img").Where( {
      $_.AlternativeText -match $match
    })
  if ($null -ne $img) {
    return $img.Parent.Parent.Parent.ChildNodes[1].TextContent
  }
  else {
    return ""
  }
}
