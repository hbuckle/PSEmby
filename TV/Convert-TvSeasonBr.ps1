function Convert-TvSeasonBr {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [ValidateNotNullOrEmpty()]
    [timespan]$MinimumLength = "00:15:00",
    [timespan]$MaximumLength = "01:00:00"
  )
  $requiredpaths = @(
    "$SourceFolder\DISKS",
    "$SourceFolder\season.json"
  )
  if (-not(Test-Path $requiredpaths)) {
    throw "Initialize-TvShowRip not run"
  }
  Get-ChildItem "$SourceFolder\DISKS" -Directory | ForEach-Object {
    Save-BRPlaylist -Path $_.FullName
  }
  $playlists = @()
  $playlists += Get-ChildItem "$SourceFolder\DISKS\*\*.json" | ForEach-Object {
    Get-Content $_.FullName -Raw | ConvertFrom-Json
  }
  $playlists = $playlists | Where-Object {
    try {
      [timespan]$_.Length -gt $MinimumLength
    }
    catch {
      $false
    }
  }
  $episodefolders = @()
  $episodefolders += Get-ChildItem $SourceFolder -Exclude "DISKS" -Directory

  $episodestodo = @()
  foreach ($folder in $episodefolders) {
    if (-not(Test-Path "$folder\episode.json")) {
      throw "$folder\episode.json not found"
    }
    $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
    if (-not($episode.complete)) {
      $episodestodo += $folder
    }
  }

  foreach ($folder in $episodestodo) {
    $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
    if ([String]::IsNullOrEmpty($episode.mpls)) {
      $playlist = $null
      $playlist = Select-ItemFromList -Title $folder.Name -List $playlists -Properties @("Details", "Path")
      if ($null -ne $playlist) {
        $episode.mpls = $playlist.Path
        $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding utf8NoBOM
        $playlist | ConvertTo-Json | Set-Content "$folder\playlist.json" -Encoding utf8NoBOM
      }
    }
  }

  foreach ($folder in $episodestodo) {
    if (Test-Path "$folder\playlist.json") {
      $playlist = Get-Content "$folder\playlist.json" | ConvertFrom-Json
      Export-BRSubs -PathToPlaylist $playlist.Path -OutputFolder $folder
      # $playlist = Get-Content "$folder\playlist.json" | ConvertFrom-Json
      # $subs = @()
      # $subs += $playlist.Tracks | Where-Object { $_.Contains("Subtitle (PGS), English") }
      # foreach ($sub in $subs) {
      #   $trackid = $sub.Split(":")[0]
      #   if (-not(Test-Path "$folder\$trackid.sup")) {
      #     & eac3to $playlist.Path 1`) ${trackid}`: "$folder\$trackid.sup"
      #     Export-ForcedSubs -InputFile "$folder\$trackid.sup" -OutputFile "$folder\${trackid}_forced.sup"
      #   }
      # }
    }
  }

  # if (-not(Test-Path "$SourceFolder\mux.json")) {
  #   Read-Host "Create mux.json"
  # }

  # foreach ($folder in $episodestodo) {
  #   $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
  #   $playlist = Get-Content "$folder\playlist.json" | ConvertFrom-Json
  #   Set-OggChapterName -InputFile "$folder\chapters.txt"
  #   $muxparams = @{
  #     "Output"      = "$folder.mkv"
  #     "Video"       = "$folder\video.h264"
  #     "AspectRatio" = "16/9"
  #     "FPS"         = "24000/1001p"
  #     "Audio"       = @()
  #     "Subtitle"    = @()
  #     "Chapters"    = "$folder\chapters.txt"
  #   }
  # }
}