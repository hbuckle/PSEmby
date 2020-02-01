function Set-SeasonEpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [string]$ShowName,
    [int]$SeasonNumber = 99,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage,
    [switch]$NoReleaseDate
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $params = @{
      PathToEpisode  = $_.FullName
      MetadataFolder = $MetadataFolder
      ShowName       = $ShowName
      SeasonNumber   = $SeasonNumber
    }
    Set-EpisodeJson @params -RedownloadPersonImage:$RedownloadPersonImage -NoReleaseDate:$NoReleaseDate
  }
  $output = Join-Path $SourceFolder "season.json"
  if (Test-Path $output) {
    $season = Get-Content $output | ConvertFrom-Json -AsHashtable
  }
  else {
    $season = @{ }
  }
  $episode1 = Get-ChildItem -LiteralPath $SourceFolder -Filter "*.json" |
  Select-Object -First 1 | Get-Content -Raw | ConvertFrom-Json -AsHashtable
  $season["lockdata"] = $true
  $season["releasedate"] = $episode1["releasedate"]
  $season["genres"] = $episode1["genres"]
  $season["year"] = $episode1["year"]
  $season | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
}