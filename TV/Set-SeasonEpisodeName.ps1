function Set-SeasonEpisodeName {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFolder,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ShowName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [int]$SeasonNumber
  )
  $season = $null
  if (Test-Path (Join-Path $SourceFolder "tmdb.json")) {
    $tmdb = Get-Content (Join-Path $SourceFolder "tmdb.json") | ConvertFrom-Json -AsHashtable -Depth 99
    if ($null -ne $tmdb["episodegroupid"]) {
      $season = Get-TvSeason -EpisodeGroupId $tmdb["episodegroupid"] -SeasonId $tmdb["seasonid"]
    }
  }
  else {
    $tmdb = @{overrides = @{ } }
  }
  if ($null -eq $season) {
    $show = Find-TvShow -Title $ShowName
    $season = Get-TvSeason -ShowId $show.id -SeasonNumber $SeasonNumber
  }
  $count = 1
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $episode = "S$($SeasonNumber.ToString().PadLeft(2,'0'))E$($count.ToString().PadLeft(2,'0'))"
    if ($null -ne $tmdb["overrides"][$episode]) {
      $title = $tmdb["overrides"][$episode]["title"]
    }
    else {
      $title = Get-TitleCaseString ($season.episodes[$count - 1].name)
    }
    $newName = Get-FileSafeName -Name "$episode - $title"
    if ($_.Name -cne "${newName}.mkv") {
      Rename-Item -LiteralPath $_.FullName -NewName "${newName}.mkv"
      $jsonPath = (Join-Path $_.DirectoryName $_.BaseName) + ".json"
      $thumbPath = (Join-Path $_.DirectoryName $_.BaseName) + "-thumb.jpg"
      $chaptersPath = Join-Path $_.DirectoryName "Chapters" $_.BaseName
      if (Test-Path $jsonPath) {
        Rename-Item -LiteralPath $jsonPath -NewName "${newName}.json"
      }
      if (Test-Path $thumbPath) {
        Rename-Item -LiteralPath $thumbPath -NewName "${newName}-thumb.jpg"
      }
      if (Test-Path $chaptersPath) {
        Rename-Item -LiteralPath $chaptersPath -NewName (Join-Path $_.DirectoryName "Chapters" $newName)
      }
    }
    $count++
  }
}
