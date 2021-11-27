function Set-FilmJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFilm,
    [string]$MetadataFolder = '\\CRUCIBLE\Metadata\metadata\People',
    [string]$TmdbId = '',
    [string]$Description = ''
  )
  $file = Get-Item $PathToFilm
  $info = Get-MediaInfo -InputFile $PathToFilm -AsHashtable
  $video = $info.media.track | Where-Object { $_.'@type' -eq 'Video' }
  Write-Verbose "Set-FilmJson : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + '\' + $file.BaseName + '.json'
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
  $credits = Get-FilmCredits -ID $film['id']
  $directors = @()
  $directors += $credits['crew'].Where( { $_['job'] -eq 'Director' })
  $actors = $credits['cast']
  $movie.title = (Get-TitleCaseString $film['title'])
  $movie.originaltitle = ''
  $movie.tagline = ''
  $movie.customrating = ''
  $movie.communityrating = $null
  $movie.releasedate = $null
  $movie.sorttitle = $file.Directory.Name
  $movie.year = ([datetime]$film['release_date']).Year
  $movie.imdbid = $film['imdb_id']
  $movie.tmdbid = $film['id'].ToString()
  if ($null -eq $movie.collections) {
    $collections = [System.Collections.ArrayList]::new()
  }
   else {
    $collections = [System.Collections.ArrayList]::new($movie.collections)
  }
  if ($null -ne $film['belongs_to_collection']) {
    $movie.tmdbcollectionid = $film['belongs_to_collection']['id']
  }
  else {
    $movie.tmdbcollectionid = ''
  }
  $movie.lockdata = $true
  $movie.genres = @()
  $movie.studios = @()
  $movie.tags = @()
  $movie.people = @()
  foreach ($genre in $film['genres']) {
    $movie.genres += $genre['name']
  }
  foreach ($person in $directors) {
    $movieDirector = [JsonMetadata.Models.JsonCastCrew]::new()
    $movieDirector.name = $person['name']
    $movieDirector.type = 'Director'
    $movieDirector.role = ''
    $movieDirector.tmdbid = $person['id']
    $tmdbperson = Get-TmdbPerson -PersonId $person.id
    if ([string]::IsNullOrEmpty($tmdbperson['imdb_id'])) {
      $movieDirector.imdbid = ''
    }
    else {
      $movieDirector.imdbid = $tmdbperson['imdb_id']
    }
    $movie.people += $movieDirector
  }
  foreach ($person in $actors) {
    $movieActor = [JsonMetadata.Models.JsonCastCrew]::new()
    $movieActor.name = $person['name']
    $movieActor.type = 'Actor'
    $movieActor.role = $person['character']
    $movieActor.tmdbid = $person['id']
    $tmdbperson = Get-TmdbPerson -PersonId $person.id
    if ([string]::IsNullOrEmpty($tmdbperson['imdb_id'])) {
      $movieActor.imdbid = ''
    }
    else {
      $movieActor.imdbid = $tmdbperson['imdb_id']
    }
    $movie.people += $movieActor
  }
  if (-not([String]::IsNullOrEmpty($Description))) {
    $movie.overview = $Description
  }
  elseif ([string]::IsNullOrEmpty($movie.overview)) {
    $desc = Get-FilmDescription $film['title']
    $movie.overview = $desc.review
  }
  if ([string]::IsNullOrEmpty($movie.parentalrating)) {
    $movie.parentalrating = Get-BBFCRating -Title $movie.title
  }
  if ($video.Sampled_Width -eq 3840 -and $video.Sampled_Height -eq 2160 -and !$collections.Contains('4K Ultra HD')) {
    $null = $collections.Add('4K Ultra HD')
  }
  $track_name = @()
  if ($video['HDR_Format'] -match 'Dolby Vision') {
    if (!$collections.Contains('Dolby Vision')) {
      $null = $collections.Add('Dolby Vision')
    }
    $mkvinfo = & mkvmerge -J $PathToFilm | ConvertFrom-Json -Depth 99 -AsHashtable
    $enhancement_layer = $mkvinfo.tracks[0].properties['tag_enhancement_layer']
    if ([string]::IsNullOrEmpty($enhancement_layer)) {
      $enhancement_layer = Read-Host "Enhancement layer ($PathToFilm) (FEL/MEL)"
      [xml]$xml = Get-Content "$PSScriptRoot/../enhancement_layer.xml"
      $xml.Tags.Tag.Simple.String = $enhancement_layer
      $xml.Save("$PSScriptRoot/../enhancement_layer.xml")
      $null = & mkvpropedit $PathToFilm --tags "all:$PSScriptRoot/../enhancement_layer.xml"
    }
    $track_name += "Dolby Vision 07.06 $enhancement_layer"
  }
  else {
    $collections.Remove('Dolby Vision')
  }
  if ($video['HDR_Format_Compatibility'] -match 'HDR10\+') {
    if (!$collections.Contains('HDR10+')) {
      $null = $collections.Add('HDR10+')
    }
    $track_name += 'HDR10+'
  }
  else {
    $collections.Remove('HDR10+')
  }
  $collections.Sort()
  $movie.collections = $collections.ToArray()
  ConvertTo-JsonSerialize -InputObject $movie | Set-Content $output -Encoding utf8NoBOM -NoNewline
  if ($track_name.Count -gt 0) {
    $null = & mkvpropedit --edit track:v1 --set "name=4K HEVC $($track_name -join ' / ')" $PathToFilm
  }
  $null = & mkvpropedit --set "title=$($movie.title)" $PathToFilm
  Set-MkvChapterName -InputFile $PathToFilm
}
