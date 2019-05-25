function Set-SeasonEpisodeName {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ShowName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber
  )
  $show = Find-TvShow -Title $ShowName
  $season = Get-TvSeason -ShowId $show.id -SeasonNumber $SeasonNumber
  $count = 1
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $episode = "S$($SeasonNumber.ToString().PadLeft(2,'0'))E$($count.ToString().PadLeft(2,'0'))"
    $title = Get-TitleCaseString ($season.episodes[$count - 1].name)
    $newName = "$episode - $title$($_.Extension)".Replace(":", ";").Replace("?", "").Replace("/", "_")
    Rename-Item -LiteralPath $_.FullName -NewName $newName
    $count++
  }
}