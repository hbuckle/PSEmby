function Set-EpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToEpisode,
    [string]$ShowName,
    [int]$SeasonNumber = 99,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage,
    [switch]$ReleaseDate,
    [ValidateSet("Netflix")]
    [string]$DescriptionSource,
    [string]$DescriptionId
  )
  $file = Get-Item $PathToEpisode
  Write-Verbose "Set-EpisodeJson : PathToEpisode = $PathToEpisode"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $episodedetails = Get-Content $output -Raw | ConvertFrom-Json -AsHashtable
  }
  else {
    $episodedetails = @{ }
  }
  $show = Import-TvShowJson -Folder $file.DirectoryName
  if ($null -eq $show) {
    try {
      $show = (Get-Variable -Scope "Script" -Name $ShowName).Value
    }
    catch {
      $show = Find-TvShow -Title $ShowName
      New-Variable -Scope "Script" -Name $ShowName -Value $show
    }
    $showid = $show["id"]
  }
  else {
    $showid = $show["tmdbid"]
  }
  if ($SeasonNumber -eq 99) {
    try {
      $SeasonNumber = [int]$file.Directory.Name.Split(" ")[1]
    }
    catch {
      throw "SeasonNumber not found"
    }
  }
  $show = Get-TvShow -ShowId $showid
  $episodeNumber = [int]($file.BaseName -split " - ")[0].Remove(0, 4)
  $episode = Get-TvEpisode -ShowId $showid -SeasonNumber $SeasonNumber -EpisodeNumber $episodeNumber
  $episodedetails["title"] = (Get-TitleCaseString $episode["name"])
  $episodedetails["sorttitle"] = ""
  $episodedetails["seasonnumber"] = $SeasonNumber
  $episodedetails["episodenumber"] = $episodeNumber
  $episodedetails["communityrating"] = $null
  if ($null -eq $episodedetails["overview"]) {
    $episodedetails["overview"] = ""
  }
  if ($ReleaseDate) {
    $episodedetails["releasedate"] = $episode["air_date"]
  }
  $episodedetails["year"] = ([datetime]$episode["air_date"]).Year
  $episodedetails["parentalrating"] = $null
  $episodedetails["customrating"] = ""
  $episodedetails["imdbid"] = ""
  $episodedetails["tvdbid"] = ""
  $episodedetails["genres"] = @()
  $episodedetails["people"] = @()
  $episodedetails["studios"] = @()
  $episodedetails["tags"] = @()
  $episodedetails["lockdata"] = $true
  foreach ($genre in $show["genres"]) {
    $episodedetails["genres"] += $genre["name"]
  }
  $directors = @()
  $directors += $episode["crew"].Where( { $_.job -eq "Director" })
  foreach ($person in $directors) {
    $episodeDirector = @{ }
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
  switch ($DescriptionSource) {
    "Netflix" {
      $description = Get-EpisodeDescriptionNetflix -Id $DescriptionId -SeasonNumber $SeasonNumber -EpisodeNumber $episodeNumber
      $episodedetails["overview"] = $description
    }
    Default { }
  }
  if (-not($episodedetails.ContainsKey("userdata"))) {
    $episodedetails["userdata"] = @()
  }
  $episodedetails | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
}