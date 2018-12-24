function Convert-TvSeasonDvd {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [ValidateNotNullOrEmpty()]
    [timespan]$MinimumLength = "00:15:00",
    [ValidateNotNullOrEmpty()]
    [String]$Sar = "64:45"
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
      $playlist = Select-ItemFromList -Title $folder.Name -List $playlists -Properties @("Name", "Video", "Audio")
      if ($null -ne $playlist) {
        $episode.vts = $playlist.Path
        $pgc = $null
        $pgc = Select-ItemFromList -List $playlist.PGC -Properties @("Number", "Detail")
        if ($null -ne $pgc) {
          $episode.pgc = $pgc.Number
        }
        $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding Ascii
        $playlist | ConvertTo-Json | Set-Content "$folder\playlist.json" -Encoding Ascii
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

  foreach ($folder in $episodestodo) {
    if (-not(Test-Path "$folder\video.vpy")) {
      Read-Host "Create $folder\video.vpy"
    }
    Convert-Video -SourceFolder $folder -X264Tune "film" -Sar $Sar
  }

  if (-not(Test-Path "$SourceFolder\mux.json")) {
    Read-Host "Create mux.json"
  }

  # foreach ($folder in $episodestodo) {
  #   $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
  #   if (-not([String]::IsNullOrEmpty($episode.mpls))) {
  #     $mux = Get-Content "$SourceFolder\mux.json" -Raw | ConvertFrom-Json
  #     $outputindex = $mux.IndexOf("--output") + 1
  #     $episodemux = $mux
  #     $episodemux[$outputindex] = "$folder.mkv"
  #     $mplsinput = $mux.Where({$_.Contains(".mpls")})
  #     $mplsinputindex = -1
  #     for ($i = 0; $i -lt $mux.Length; $i++) {
  #       if ($mux[$i] -eq $mplsinput) {
  #         $mplsinputindex = $i
  #         break;
  #       }
  #     }
  #     $episodemux[$mplsinputindex] = $episode.mpls
  #     $encoding = [Text.UTF8Encoding]::new($false)
  #     [IO.File]::WriteAllLines("$folder\mux.json", ($episodemux | ConvertTo-Json -Depth 99), $encoding)
  #     & mkvmerge "@$folder\mux.json"
  #     $episode.complete = $true
  #     $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding Ascii
  #   }
  # }
}