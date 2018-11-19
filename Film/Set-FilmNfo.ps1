function Set-FilmNfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFilm,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage
  )
  $file = Get-Item $PathToFilm
  Write-Verbose "Set-FilmNfo : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".nfo"
  if (Test-Path $output) {
    $movie = [embymetadata.movie]::Load($output)
  }
  else {
    $movie = [embymetadata.movie]::new()
  }
  if ([String]::IsNullOrEmpty($movie.tmdbid)) {
    $film = Find-Film -Title $file.BaseName
  }
  else {
    $film = Get-Film -ID $movie.tmdbid
  }
  $credits = Get-FilmCredits -ID $film.Id
  $directors = @()
  $directors += $credits.crew.Where({$_.job -eq "Director" })
  $actors = $credits.cast
  $movie.title = (Get-TitleCaseString $film.title)
  $movie.sorttitle = $file.Directory.Name
  $movie.year = ([datetime]$film.release_date).Year.ToString()
  $movie.tmdbid = $film.id.ToString()
  $movie.lockdata = "true"
  $movie.director = @()
  $movie.actor = @()
  foreach ($director in $directors) {
    $movieDirector = [embymetadata.director]::new()
    $directorName = "$($director.name) ($($director.id))"
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $director.name -PersonId $director.id
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $director.name -PersonId $director.id -Overwrite
    }
    $movieDirector.Value = $directorName
    $movie.director += $movieDirector
  }
  foreach ($actor in $actors) {
    $movieActor = [embymetadata.actor]::new()
    $actorName = "$($actor.name) ($($actor.id))"
    $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $actor.name -PersonId $actor.id
    if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
      Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $actor.name -PersonId $actor.id -Overwrite
    }
    if (Test-Path $imagepath) {
      $movieActor.thumb = $imagepath
    }
    $movieActor.name = $actorName
    $movieActor.type = "Actor"
    $movieActor.role = $actor.character
    $movie.actor += $movieActor
  }
  if ([string]::IsNullOrEmpty($movie.plot)) {
    $description = Get-FilmDescription $film.Title
    $movie.plot = $description.review
  }
  $movie.Save($output)
}