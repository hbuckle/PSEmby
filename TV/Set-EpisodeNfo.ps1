function Set-EpisodeNfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToEpisode,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ShowName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage
  )
  $file = Get-Item $PathToEpisode
  $output = $file.DirectoryName + "\" + $file.BaseName + ".nfo"
  $json = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $episodedetails = [embymetadata.episodedetails]::Load($output)
  }
  else {
    $episodedetails = [embymetadata.episodedetails]::new()
  }
  if (Test-Path $json) {
    $additional = Get-Content $json -Raw | ConvertFrom-Json
  }
  else {
    $additional = $null
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
  if ($null -ne $additional) {
    if (-not([String]::IsNullOrEmpty($additional.tmdb_episode_number))) {
      $episode = $season.episodes | Where-Object episode_number -eq $additional.tmdb_episode_number
    }
  }
  else {
    $episode = $season.episodes | Where-Object episode_number -eq $episodeNumber
  }
  if ($episode) {
    $directors = @()
    $directors += $episode.crew.Where( {$_.job -eq "Director" })
    $episodedetails.title = (Get-TitleCaseString $episode.name)
    $episodedetails.lockdata = "true"
    $episodedetails.episode = $episodeNumber
    $episodedetails.season = $SeasonNumber
    if ($null -ne $episode.air_date) {
      $episodedetails.year = ([datetime]$episode.air_date).Year.ToString()
    }
    $episodedetails.director = @()
    $episodedetails.actor = @()
    foreach ($director in $directors) {
      $episodeDirector = [embymetadata.director]::new()
      $directorName = "$($director.Name) ($($director.Id))"
      $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $director.name -PersonId $director.id
      if (-not(Test-Path $imagepath) -or $RedownloadPersonImage) {
        Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $director.name -PersonId $director.id -Overwrite
      }
      $episodeDirector.Value = $directorName
      $episodedetails.director += $episodeDirector
    }
    $episodedetails.Save($output)
  }
}