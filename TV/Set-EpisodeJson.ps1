function Set-EpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToEpisode,
    [string]$ShowName,
    [int]$SeasonNumber = 99,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage,
    [switch]$NoReleaseDate,
    [ValidateSet("Netflix")]
    [string]$DescriptionSource,
    [string]$DescriptionId
  )
  $file = Get-Item $PathToEpisode
  Write-Verbose "Set-EpisodeJson : PathToEpisode = $PathToEpisode"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $episodedetails = Read-EpisodeJson -Path $output
  }
  else {
    $episodedetails = [JsonMetadata.Models.JsonEpisode]::new()
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
  $episodeId = ($file.BaseName -split " - ")[0]
  $episodeNumber = [int]($file.BaseName -split " - ")[0].Remove(0, 4)
  $episode = $null
  if (Test-Path (Join-Path $file.DirectoryName "tmdb.json")) {
    $tmdb = Get-Content (Join-Path $file.DirectoryName "tmdb.json") | ConvertFrom-Json -AsHashtable -Depth 99
    if ($null -ne $tmdb["episodegroupid"]) {
      $season = Get-TvSeason -EpisodeGroupId $tmdb["episodegroupid"] -SeasonId $tmdb["seasonid"]
      $episode = $season["episodes"] | Where-Object order -eq ($episodeNumber - 1)
      $episode = Get-TvEpisode -ShowId $showid -SeasonNumber $episode["season_number"] -EpisodeNumber $episode["episode_number"]
    }
  }
  else {
    $tmdb = @{overrides = @{ } }
  }
  if ($null -eq $episode) {
    $episode = Get-TvEpisode -ShowId $showid -SeasonNumber $SeasonNumber -EpisodeNumber $episodeNumber
  }
  $episodedetails.title = (Get-TitleCaseString $episode["name"])
  $episodedetails.sorttitle = ""
  $episodedetails.seasonnumber = $SeasonNumber
  $episodedetails.episodenumber = $episodeNumber
  $episodedetails.communityrating = $null
  if ($null -eq $episodedetails.overview) {
    $episodedetails.overview = ""
  }
  if (!$NoReleaseDate -and ![string]::IsNullOrEmpty($episode["air_date"])) {
    $episodedetails.releasedate = [datetime]::ParseExact($episode["air_date"], "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
  }
  $episodedetails.year = ([datetime]::ParseExact($episode["air_date"], "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)).Year
  $episodedetails.parentalrating = $null
  $episodedetails.customrating = ""
  $episodedetails.imdbid = ""
  $episodedetails.tvdbid = ""
  $episodedetails.genres = @()
  $episodedetails.people = @()
  $episodedetails.studios = @()
  $episodedetails.tags = @()
  $episodedetails.lockdata = $true
  $episodedetails.path = ""
  foreach ($genre in $show["genres"]) {
    $episodedetails.genres += $genre["name"]
  }
  $directors = @()
  $directors += $episode["crew"].Where( { $_.job -eq "Director" })
  foreach ($person in $directors) {
    $episodeDirector = [JsonMetadata.Models.JsonCastCrew]::new()
    $personfolder = Get-PersonFolder -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    Set-PersonJson -Path (Join-Path $personfolder "person.json") -TmdbId $person["id"]
    $personjson = Read-PersonJson -Path (Join-Path $personfolder "person.json")
    $episodeDirector.name = $person["name"]
    $episodeDirector.type = "Director"
    $episodeDirector.role = ""
    $episodeDirector.tmdbid = $person["id"]
    $episodeDirector.path = $personfolder
    $embymatches = @()
    $embymatches += Get-EmbyPerson -Name $person["name"]
    if ($embymatches.Count -eq 1) {
      $episodeDirector.id = $embymatches[0].Id
    }
    if ($null -ne $personjson.imdbid) {
      $episodeDirector.imdbid = $personjson.imdbid
    }
    else {
      $episodeDirector.imdbid = ""
    }
    $episodedetails.people += $episodeDirector
  }
  switch ($DescriptionSource) {
    "Netflix" {
      $description = Get-EpisodeDescriptionNetflix -Id $DescriptionId -SeasonNumber $SeasonNumber -EpisodeNumber $episodeNumber
      $episodedetails.overview = $description
    }
    Default { }
  }
  if ($null -ne $tmdb["overrides"][$episodeId]) {
    foreach ($property in $tmdb["overrides"][$episodeId].GetEnumerator()) {
      $episodedetails.$($property.Key) = $property.Value
    }
  }
  ConvertTo-JsonSerialize -InputObject $episodedetails | Set-Content $output -Encoding utf8NoBOM
}