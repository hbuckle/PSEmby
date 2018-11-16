function Initialize-TvShowRip {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [string]$ShowName,
    [string]$SortName,
    [string]$TmdbId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$Seasons,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateSet("UK", "US")]
    [string]$Region
  )
  if (Test-Path "$SourceFolder\show.json") {
    $show = Get-Content "$SourceFolder\show.json" | ConvertFrom-Json
  }
  else {
    if ([String]::IsNullOrEmpty($ShowName)) {
      throw "Missing ShowName"
    }
    if ([String]::IsNullOrEmpty($TmdbId)) {
      throw "Missing TmdbId"
    }
    $show = @{
      "name"   = $ShowName
      "tmdbid" = $TmdbId
    }
    if (-not([String]::IsNullOrEmpty($SortName))) {
      $show["sortname"] = $SortName
    }
    else {
      $show["sortname"] = $ShowName
    }
    $show | ConvertTo-Json | Set-Content "$SourceFolder\show.json" -Encoding Ascii
  }

  switch ($Region) {
    "UK" { $subfolder = "Series" }
    "US" { $subfolder = "Season" }
    Default {}
  }
  for ($i = 1; $i -le $Seasons; $i++) {
    $number = $i.ToString().PadLeft(2, "0")
    $seasonpath = "$SourceFolder\${subfolder}${number}"
    if (-not(Test-Path $seasonpath)) {
      New-Item $seasonpath -ItemType Directory | Out-Null
      [int]$episodecount = Read-Host "Number of episodes in $subfolder $number"
      @{
        "number"       = $i
        "episodecount" = $episodecount
        "seasonid"     = (Get-TvSeason -ShowId $TmdbId -SeasonNumber $i).Id
      } | ConvertTo-Json | Set-Content "$seasonpath\season.json" -Encoding Ascii
      New-Item "$seasonpath\DISKS" -ItemType Directory | Out-Null
      New-SeasonFolder -SourceFolder $seasonpath -SeasonNumber $i -NumberOfEpisodes $episodecount
    }
  }
}