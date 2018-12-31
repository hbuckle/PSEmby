function Convert-TvSeasonDvd {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [ValidateNotNullOrEmpty()]
    [timespan]$MinimumLength = "00:15:00",
    [switch]$ConvertVideo,
    [int[]]$AudioTracks = @(0)
  )
  $requiredpaths = @(
    "$SourceFolder\DISKS",
    "$SourceFolder\season.json"
  )
  if (-not(Test-Path $requiredpaths)) {
    throw "Initialize-TvShowRip not run"
  }
  Get-ChildItem "$SourceFolder\DISKS" -Directory | ForEach-Object {
    Save-DVDPlaylist -Path $_.FullName
  }
  $playlists = @()
  $playlists += Get-ChildItem "$SourceFolder\DISKS\*\*.json" | ForEach-Object {
    Get-Content $_.FullName -Raw | ConvertFrom-Json
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
    if ([String]::IsNullOrEmpty($episode.vts)) {
      $playlist = $null
      $playlist = Select-ItemFromList -Title $folder.Name -List $playlists -Properties @("Name", "Video", "PGC")
      if ($null -ne $playlist) {
        $episode.vts = $playlist.Path
        $pgc = $null
        $pgc = Select-ItemFromList -List $playlist.PGC -Properties @("Number", "Detail")
        if ($null -ne $pgc) {
          $episode.pgc = $pgc.Number
        }
        $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding utf8NoBOM
        $playlist | ConvertTo-Json | Set-Content "$folder\playlist.json" -Encoding utf8NoBOM
      }
    }
  }

  foreach ($folder in $episodestodo) {
    if (Test-Path "$folder\episode.json") {
      $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
      Export-Pgc -PathToIfo $episode.vts -PgcNumber $episode.pgc -OutputFolder $folder.FullName
      Get-DVDAudioDelay -PathToPlaylist "$folder\playlist.json" -PathToPgcDemuxLog "$folder\LogFile.txt"
    }
  }

  if ($ConvertVideo) {
    foreach ($folder in $episodestodo) {
      if (-not(Test-Path "$folder\video.vpy")) {
        Read-Host "Create $folder\video.vpy"
      }
      $playlist = Get-Content "$folder\playlist.json" | ConvertFrom-Json
      $sar = Get-Sar -Framesize $playlist.Video.Framesize -DAR $playlist.Video.AspectRatio
      Convert-Video -SourceFolder $folder -X264Tune "film" -Sar $sar
    }
  }

  foreach ($folder in $episodestodo) {
    $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
    $playlist = Get-Content "$folder\playlist.json" | ConvertFrom-Json
    $muxparams = @{
      "Output"      = "$folder.mkv"
      "Video"       = if ($ConvertVideo) { "$folder\video.h264" } else { "$folder\VideoFile.m2v" }
      "AspectRatio" = $playlist.Video.AspectRatio
      "FPS"         = switch ($playlist.Video.Format) {
        "PAL" { "25p" }
        "NTSC" { "24000/1001p" }
        Default { throw "Unrecognised format" }
      }
      "Audio"       = @()
      "Chapters"    = "$folder\chapters.txt"
    }
    for ($i = 0; $i -lt $playlist.Audio.Count; $i++) {
      if ($AudioTracks.Contains($i)) {
        $audio = [AudioTrack]::new()
        $audio.Path = "$folder\AudioFile_8${i}.ac3"
        $audio.Language = "eng"
        $audio.Delay = $playlist.Audio[$i].Delay
        $muxparams.Audio += $audio
      }
    }
    $mux = Get-MkvToolnixOption @muxparams
    $mux | Set-Content "$folder\mux.json" -Encoding utf8NoBOM
    & mkvmerge "@$folder\mux.json"
    $episode.complete = $true
    $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding utf8NoBOM
  }
}