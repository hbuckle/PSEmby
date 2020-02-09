function Set-FilmJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFilm,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [string]$TmdbId = "",
    [string]$Description = ""
  )
  $file = Get-Item $PathToFilm
  Write-Verbose "Set-FilmJson : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $movie = Read-FilmJson -Path $output
  }
  else {
    $movie = [JsonMetadata.Models.JsonMovie]::new()
  }
  if (-not([String]::IsNullOrEmpty($TmdbId))) {
    $film = Get-Film -ID $TmdbId
  }
  elseif ([String]::IsNullOrEmpty($movie.tmdbid)) {
    $film = Find-Film -Title $file.BaseName
  }
  else {
    $film = Get-Film -ID $movie.tmdbid
  }
  $credits = Get-FilmCredits -ID $film["id"]
  $directors = @()
  $directors += $credits["crew"].Where( { $_["job"] -eq "Director" })
  $actors = $credits["cast"]
  $movie.title = (Get-TitleCaseString $film["title"])
  $movie.originaltitle = ""
  $movie.tagline = ""
  $movie.customrating = ""
  $movie.communityrating = $null
  $movie.releasedate = $null
  $movie.sorttitle = $file.Directory.Name
  $movie.year = ([datetime]$film["release_date"]).Year
  $movie.imdbid = $film["imdb_id"]
  $movie.tmdbid = $film["id"].ToString()
  $movie.path = ""
  if ($null -ne $film["belongs_to_collection"]) {
    $movie.tmdbcollectionid = $film["belongs_to_collection"]["id"]
  }
  else {
    $movie.tmdbcollectionid = ""
  }
  $movie.lockdata = $true
  $movie.genres = @()
  $movie.studios = @()
  $movie.tags = @()
  $movie.people = @()
  foreach ($genre in $film["genres"]) {
    $movie.genres += $genre["name"]
  }
  foreach ($person in $directors) {
    $movieDirector = [JsonMetadata.Models.JsonCastCrew]::new()
    $personfolder = Get-PersonFolder -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    Set-PersonJson -Path (Join-Path $personfolder "person.json") -TmdbId $person["id"]
    $personjson = Read-PersonJson -Path (Join-Path $personfolder "person.json")
    $movieDirector.name = $person["name"]
    $movieDirector.type = "Director"
    $movieDirector.role = ""
    $movieDirector.tmdbid = $person["id"]
    $movieDirector.path = $personfolder
    $embymatches = @()
    $embymatches += Get-EmbyPerson -Name $person["name"]
    if ($embymatches.Count -eq 1) {
      $movieDirector.id = $embymatches[0].Id
    }
    if ($null -ne $personjson.imdbid) {
      $movieDirector.imdbid = $personjson.imdbid
    }
    else {
      $movieDirector.imdbid = ""
    }
    $movie.people += $movieDirector
  }
  foreach ($person in $actors) {
    $movieActor = [JsonMetadata.Models.JsonCastCrew]::new()
    $personfolder = Get-PersonFolder -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    Set-PersonJson -Path (Join-Path $personfolder "person.json") -TmdbId $person["id"]
    $personjson = Read-PersonJson -Path (Join-Path $personfolder "person.json")
    $movieActor.name = $person["name"]
    $movieActor.type = "Actor"
    $movieActor.role = $person["character"]
    $movieActor.tmdbid = $person["id"]
    $movieActor.path = $personfolder
    $embymatches = @()
    $embymatches += Get-EmbyPerson -Name $person["name"]
    if ($embymatches.Count -eq 1) {
      $movieActor.id = $embymatches[0].Id
    }
    if ($null -ne $personjson.imdbid) {
      $movieActor.imdbid = $personjson.imdbid
    }
    else {
      $movieActor.imdbid = ""
    }
    $movie.people += $movieActor
  }
  if (-not([String]::IsNullOrEmpty($Description))) {
    $movie.overview = $Description
  }
  elseif ([string]::IsNullOrEmpty($movie.overview)) {
    $desc = Get-FilmDescription $film["title"]
    $movie.overview = $desc.review
  }
  if ([string]::IsNullOrEmpty($movie.parentalrating)) {
    $movie.parentalrating = Get-FilmRating -Title $movie.title
  }
  ConvertTo-JsonSerialize -InputObject $movie | Set-Content $output -Encoding utf8NoBOM -NoNewline
}