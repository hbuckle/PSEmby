function Convert-TvSeasonBr {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [ValidateNotNullOrEmpty()]
    [timespan]$MinimumLength = "00:15:00"
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
      $playlist = $playlists | Where-Object {
        try {
          [timespan]$_.Length -gt $MinimumLength
        } catch {
          $false
        }
      } | Out-GridView -PassThru -Title $folder.Name
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
      $subs = @()
      $subs += $playlist.Tracks | Where-Object { $_.Contains("Subtitle (PGS), English") }
      foreach ($sub in $subs) {
        $trackid = $sub.Split(":")[0]
        if (-not(Test-Path "$folder\$trackid.sup")) {
          & eac3to $playlist.Path 1`) ${trackid}`: "$folder\$trackid.sup"
          Export-ForcedSubs -InputFile "$folder\$trackid.sup" -OutputFile "$folder\${trackid}_forced.sup"
        }
      }
    }
  }

  if (-not(Test-Path "$SourceFolder\mux.json")) {
    Read-Host "Create mux.json"
  }

  foreach ($folder in $episodestodo) {
    $episode = Get-Content "$folder\episode.json" | ConvertFrom-Json
    if (-not([String]::IsNullOrEmpty($episode.mpls))) {
      $mux = Get-Content "$SourceFolder\mux.json" -Raw | ConvertFrom-Json
      $outputindex = $mux.IndexOf("--output") + 1
      $episodemux = $mux
      $episodemux[$outputindex] = "$folder.mkv"
      $mplsinput = $mux.Where({$_.Contains(".mpls")})
      $mplsinputindex = -1
      for ($i = 0; $i -lt $mux.Length; $i++) {
        if ($mux[$i] -eq $mplsinput) {
          $mplsinputindex = $i
          break;
        }
      }
      $episodemux[$mplsinputindex] = $episode.mpls
      $encoding = [Text.UTF8Encoding]::new($false)
      [IO.File]::WriteAllLines("$folder\mux.json", ($episodemux | ConvertTo-Json -Depth 99), $encoding)
      & mkvmerge "@$folder\mux.json"
      $episode.complete = $true
      $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding utf8NoBOM
    }
  }
}