function Set-FilmJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFilm,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [string]$TmdbId = "",
    [string]$Description = "",
    [switch]$RedownloadPersonImage
  )
  $file = Get-Item $PathToFilm
  Write-Verbose "Set-FilmJson : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $movie = Get-Content $output -Raw | ConvertFrom-Json -AsHashtable
    $null = $movie.Remove("__type")
  }
  else {
    $movie = @{ }
  }
  if (-not([String]::IsNullOrEmpty($TmdbId))) {
    $film = Get-Film -ID $TmdbId
  }
  elseif ([String]::IsNullOrEmpty($movie["tmdbid"])) {
    $film = Find-Film -Title $file.BaseName
  }
  else {
    $film = Get-Film -ID $movie["tmdbid"]
  }
  $credits = Get-FilmCredits -ID $film["id"]
  $directors = @()
  $directors += $credits["crew"].Where( { $_["job"] -eq "Director" })
  $actors = $credits["cast"]
  $movie["title"] = (Get-TitleCaseString $film["title"])
  $movie["originaltitle"] = ""
  $movie["tagline"] = ""
  $movie["customrating"] = ""
  $movie["originalaspectratio"] = ""
  $movie["sorttitle"] = $file.Directory.Name
  $movie["year"] = ([datetime]$film["release_date"]).Year
  $movie["imdb"] = ""
  $movie["tmdbid"] = $film["id"].ToString()
  if ($null -ne $film["belongs_to_collection"]) {
    $movie["tmdbcollectionid"] = $film["belongs_to_collection"]["id"]
  }
  else {
    $movie["tmdbcollectionid"] = ""
  }
  $movie["lockdata"] = $true
  $movie["genres"] = @()
  $movie["studios"] = @()
  $movie["tags"] = @()
  $movie["people"] = @()
  foreach ($genre in $film["genres"]) {
    $movie["genres"] += $genre["name"]
  }
  foreach ($person in $directors) {
    $movieDirector = @{ }
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"] -Overwrite
    }
    if (Test-Path $imagepath) {
      $movieDirector["thumb"] = $imagepath
    }
    else {
      $movieDirector["thumb"] = ""
    }
    $movieDirector["name"] = $person["name"]
    $movieDirector["type"] = "Director"
    $movieDirector["role"] = ""
    $movieDirector["tmdbid"] = $person["id"]
    $tmdbperson = Get-TmdbPerson -PersonId $person["id"]
    if ($null -ne $tmdbperson["imdb_id"]) {
      $movieDirector["imdbid"] = $tmdbperson["imdb_id"]
    }
    else {
      $movieDirector["imdbid"] = ""
    }
    $movie["people"] += $movieDirector
  }
  foreach ($person in $actors) {
    $movieActor = @{ }
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"]
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["id"] -Overwrite
    }
    if (Test-Path $imagepath) {
      $movieActor["thumb"] = $imagepath
    }
    else {
      $movieActor["thumb"] = ""
    }
    $movieActor["name"] = $person["name"]
    $movieActor["type"] = "Actor"
    $movieActor["role"] = $person["character"]
    $movieActor["tmdbid"] = $person["id"]
    $tmdbperson = Get-TmdbPerson -PersonId $person["id"]
    if ($null -ne $tmdbperson["imdb_id"]) {
      $movieActor["imdbid"] = $tmdbperson["imdb_id"]
    }
    else {
      $movieActor["imdbid"] = ""
    }
    $movie["people"] += $movieActor
  }
  if (-not([String]::IsNullOrEmpty($Description))) {
    $movie["overview"] = $Description
  }
  elseif ([string]::IsNullOrEmpty($movie["overview"])) {
    $desc = Get-FilmDescription $film["title"]
    $movie["overview"] = $desc.review
  }
  if (-not($movie.ContainsKey("userdata"))) {
    $movie["userdata"] = @()
  }
  if ([string]::IsNullOrEmpty($movie["parentalrating"])) {
    $movie["parentalrating"] = Get-FilmRating -Title $movie["title"]
  }
  $movie | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
}