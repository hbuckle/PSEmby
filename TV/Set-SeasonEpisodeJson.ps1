function Set-SeasonEpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,

    [string]$ShowName,

    [int]$SeasonNumber = 99,

    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",

    [switch]$NoReleaseDate
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $params = @{
      PathToEpisode  = $_.FullName
      MetadataFolder = $MetadataFolder
      ShowName       = $ShowName
      SeasonNumber   = $SeasonNumber
    }
    Set-EpisodeJson @params -NoReleaseDate:$NoReleaseDate
  }
  $output = Join-Path $SourceFolder "season.json"
  if (Test-Path $output) {
    $seasonjson = Read-SeasonJson -Path $output
  }
  else {
    $seasonjson = [JsonMetadata.Models.JsonSeason]::new()
  }
  $episode1 = Get-ChildItem -LiteralPath $SourceFolder -Filter "*.json" |
    Select-Object -First 1 |
    ForEach-Object { Read-EpisodeJson -Path $_.FullName }
  $seasonjson.lockdata = $true
  $seasonjson.releasedate = $episode1.releasedate
  $seasonjson.genres = $episode1.genres
  $seasonjson.year = $episode1.year
  ConvertTo-JsonSerialize -InputObject $seasonjson | Set-Content $output -Encoding utf8NoBOM -NoNewline
}