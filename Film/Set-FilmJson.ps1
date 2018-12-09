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
  Write-Verbose "Set-FilmNfo : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $movie = Get-Content $output -Raw | ConvertFrom-Json -AsHashtable
  }
  else {
    $movie = @{}
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
  $credits = Get-FilmCredits -ID $film.Id
  $directors = @()
  $directors += $credits.crew.Where({ $_.job -eq "Director" })
  $actors = $credits.cast
  $movie["title"] = (Get-TitleCaseString $film.title)
  $movie["originaltitle"] = ""
  $movie["tagline"] = ""
  $movie["customrating"] = ""
  $movie["originalaspectratio"] = ""
  $movie["sorttitle"] = $file.Directory.Name
  $movie["year"] = ([datetime]$film.release_date).Year.ToString()
  $movie["imdb"] = ""
  $movie["tmdbid"] = $film.id.ToString()
  $movie["tmdbcollectionid"] = ""
  $movie["lockdata"] = $true
  $movie["genres"] = @()
  $movie["studios"] = @()
  $movie["tags"] = @()
  $movie["people"] = @()
  foreach ($person in $directors) {
    $movieDirector = @{}
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person.name -PersonId $person.id
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $person.name -PersonId $person.id -Overwrite
    }
    if (Test-Path $imagepath) {
      $movieDirector["thumb"] = $imagepath
    }
    else {
      $movieDirector["thumb"] = ""
    }
    $movieDirector["name"] = $person.name
    $movieDirector["type"] = "Director"
    $movieDirector["role"] = ""
    $movieDirector["tmdbid"] = $person.id
    $movieDirector["imdbid"] = $person.imdb_id
    $movie["people"] += $movieDirector
  }
  foreach ($person in $actors) {
    $movieActor = @{}
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person.name -PersonId $person.id
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $person.name -PersonId $person.id -Overwrite
    }
    if (Test-Path $imagepath) {
      $movieActor["thumb"] = $imagepath
    }
    else {
      $movieActor["thumb"] = ""
    }
    $movieActor["name"] = $person.name
    $movieActor["type"] = "Actor"
    $movieActor["role"] = $person.character
    $movieActor["tmdbid"] = $person.id
    $movieActor["imdbid"] = $person.imdb_id
    $movie["people"] += $movieActor
  }
  if (-not([String]::IsNullOrEmpty($Description))) {
    $movie["overview"] = $Description
  }
  elseif ([string]::IsNullOrEmpty($movie["overview"])) {
    $desc = Get-FilmDescription $film.Title
    $movie["overview"] = $desc.review
  }
  $movie | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
}