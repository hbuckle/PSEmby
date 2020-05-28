function Initialize-TvShowRip {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,

    [string]$ShowName,

    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$Seasons,

    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateSet("UK", "US")]
    [string]$Region
  )
  if (Test-Path "$SourceFolder\show.json") {
    $show = Get-Content "$SourceFolder\show.json" | ConvertFrom-Json
  }
  else {
    $tvshow = Find-TvShow -Title $ShowName
    $show = @{
      "name"   = $ShowName
      "tmdbid" = $tvshow.id
    }
    $show | ConvertTo-Json | Set-Content "$SourceFolder\show.json" -Encoding utf8NoBOM
  }

  switch ($Region) {
    "UK" { $subfolder = "Series" }
    "US" { $subfolder = "Season" }
    Default { }
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
        "seasonid"     = (Get-TvSeason -ShowId $tvshow.id -SeasonNumber $i)["Id"]
      } | ConvertTo-Json | Set-Content "$seasonpath\season.json" -Encoding utf8NoBOM
      New-Item "$seasonpath\DISKS" -ItemType Directory | Out-Null
      New-SeasonFolder -SourceFolder $seasonpath -SeasonNumber $i -NumberOfEpisodes $episodecount
    }
  }
}