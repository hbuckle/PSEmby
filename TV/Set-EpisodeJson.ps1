function Set-EpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToEpisode,
    [string]$ShowName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage
  )
  $file = Get-Item $PathToEpisode
  Write-Verbose "Set-EpisodeJson : PathToEpisode = $PathToEpisode"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $episodedetails = Get-Content $output -Raw | ConvertFrom-Json -AsHashtable
  }
  else {
    $episodedetails = @{}
  }
  $show = Import-TvShowNfo -Folder $file.DirectoryName
  if ($null -eq $show) {
    try {
      $show = (Get-Variable -Scope "Script" -Name $ShowName).Value
    }
    catch {
      $show = Find-TvShow -Title $ShowName
      New-Variable -Scope "Script" -Name $ShowName -Value $show
    }
    $showid = $show.id
  }
  else {
    $showid = $show.tmdbid
  }
  $season = Get-TvSeason -ShowId $showid -SeasonNumber $SeasonNumber
  $episodeNumber = [int]($file.BaseName -split " - ")[0].Remove(0, 4)
  $episode = $season["episodes"] | Where-Object episode_number -eq $episodeNumber
  $episodedetails["title"] = (Get-TitleCaseString $episode["title"])
  $episodedetails["sorttitle"] = ""
  $episodedetails["seasonnumber"] = $SeasonNumber
  $episodedetails["episodenumber"] = $episodeNumber
  $episodedetails["communityrating"] = ""
  # $episodedetails["releasedate"]
  $episodedetails["year"] = ([datetime]$episode["air_date"]).Year
  $episodedetails["parentalrating"] = $null
  $episodedetails["customrating"] = ""
  $episodedetails["originalaspectratio"] = ""
  $episodedetails["imdb"] = ""
  $episodedetails["tvdbid"] = ""
  $episodedetails["genres"] = @()
  $episodedetails["people"] = @()
  $episodedetails["studios"] = @()
  $episodedetails["tags"] = @()
  $episodedetails["lockdata"] = $true

  $directors = @()
  $directors += $episode["crew"].Where( {$_.job -eq "Director" })
  foreach ($person in $directors) {
    $episodeDirector = @{}
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"] -Overwrite
    }
    if (Test-Path $imagepath) {
      $episodeDirector["thumb"] = $imagepath
    }
    else {
      $episodeDirector["thumb"] = ""
    }
    $episodeDirector["name"] = $person["name"]
    $episodeDirector["type"] = "Director"
    $episodeDirector["role"] = ""
    $episodeDirector["tmdbid"] = $person["id"]
    $tmdbperson = Get-TmdbPerson -PersonId $person["id"]
    if ($null -ne $tmdbperson["imdb_id"]) {
      $episodeDirector["imdbid"] = $tmdbperson["imdb_id"]
    }
    else {
      $episodeDirector["imdbid"] = ""
    }
    $episodedetails["people"] += $episodeDirector
  }

  $episodedetails | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
}