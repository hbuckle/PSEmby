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
  if ($null -eq $movie.collections) {
    $movie.collections = @()
  }
  # $movie.path = ""
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
    $movieDirector.name = $person["name"]
    $movieDirector.type = "Director"
    $movieDirector.role = ""
    $movieDirector.tmdbid = $person["id"]
    $tmdbperson = Get-TmdbPerson -PersonId $person.id
    if ([string]::IsNullOrEmpty($tmdbperson["imdb_id"])) {
      $movieDirector.imdbid = ""
    }
    else {
      $movieDirector.imdbid = $tmdbperson["imdb_id"]
    }
    $movie.people += $movieDirector
  }
  foreach ($person in $actors) {
    $movieActor = [JsonMetadata.Models.JsonCastCrew]::new()
    $movieActor.name = $person["name"]
    $movieActor.type = "Actor"
    $movieActor.role = $person["character"]
    $movieActor.tmdbid = $person["id"]
    $tmdbperson = Get-TmdbPerson -PersonId $person.id
    if ([string]::IsNullOrEmpty($tmdbperson["imdb_id"])) {
      $movieActor.imdbid = ""
    }
    else {
      $movieActor.imdbid = $tmdbperson["imdb_id"]
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
    $movie.parentalrating = Get-BBFCRating -Title $movie.title
  }
  ConvertTo-JsonSerialize -InputObject $movie | Set-Content $output -Encoding utf8NoBOM -NoNewline
}
