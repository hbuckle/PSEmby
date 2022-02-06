function Get-FilmMissingDataReport {
  [CmdletBinding()]
  param (
    [string]$Path = "\\CRUCIBLE\Films"
  )
  Get-ChildItem -Path $Path -Directory | ForEach-Object {
    $current = $_.FullName
    try {
      $props = [ordered]@{
        Folder           = $_.Name
        FileName         = ""
        Extension        = ""
        Poster           = $false
        Backdrop         = 0
        Logo             = $false
        Trailer          = $false
        Json             = $false
        VideoCodec       = ""
        Width            = 0
        Height           = 0
        FrameRate        = 0
        AudioTracks      = 0
        AudioCodecs      = @()
        InternalChapters = $false
        ExternalChapters = $false
        Title            = ""
        SortTitle        = ""
        Plot             = $false
        Director         = $false
        Actors           = $false
        Rating           = ""
        TmdbId           = ""
        TmdbCollectionId = ""
        Container        = ""
      }
      $filmFile = Get-Item "$($_.FullName)\*.mkv"
      $fileInfo = Get-VideoInfo -Path $filmFile.FullName
      $videoStream = $fileInfo["streams"] | Where-Object { $_["codec_type"] -eq "video" } | Select-Object -First 1
      $audioStreams = @($fileInfo["streams"] | Where-Object { $_["codec_type"] -eq "audio" })

      $props.FileName = $filmFile.BaseName
      $props.Extension = $filmFile.Extension
      $props.Poster = (Test-Path "$($_.FullName)\folder.jpg")
      $props.Backdrop = @(Get-ChildItem $_.FullName -Filter "backdrop*").Count
      $props.Logo = (Test-Path "$($_.FullName)\logo.png")
      $props.Trailer = (Test-Path "$($_.FullName)\Trailers\*.mkv")
      $props.Json = (Test-Path "$($_.FullName)\*.json")
      $props.VideoCodec = $videoStream["codec_name"]
      $props.Height = $videoStream["height"]
      $props.Width = $videoStream["width"]
      $props.FrameRate = $videoStream["r_frame_rate"]
      $props.AudioTracks = $audioStreams.Count
      foreach ($track in $audioStreams) {
        $props.AudioCodecs += $track["codec_name"]
      }
      $props.InternalChapters = ($fileInfo.ContainsKey("chapters") -and $fileinfo["chapters"].Count -gt 0)
      $props.ExternalChapters = @(Get-ChildItem "$($_.FullName)\Chapters" -Exclude ".ignore" -ErrorAction SilentlyContinue).Count -gt 0
      if ($props.Json) {
        $jsonPath = (Resolve-Path "$($_.FullName)\*.json").ProviderPath
        $movie = Get-Content $jsonPath -Raw | ConvertFrom-Json -AsHashtable
        $props.Title = $movie["title"]
        $props.SortTitle = $movie["sorttitle"]
        $props.Plot = (-not([string]::IsNullOrEmpty($movie["overview"])))
        $props.Director = (@($movie["people"] | Where-Object { $_["type"] -eq "Director" }).Count -gt 0)
        $props.Actors = (@($movie["people"] | Where-Object { $_["type"] -eq "Actor" }).Count -gt 0)
        $props.Rating = $movie["parentalrating"]
        $props.TmdbId = $movie["tmdbid"]
        $props.TmdbCollectionId = $movie["tmdbcollectionid"]
      }
      if ($fileInfo["format"].ContainsKey("tags")) {
        $props.Container = $fileInfo["format"]["tags"]["encoder"]
      }
      Write-Output (New-Object PSObject -Property $props)
    }
    catch {
      Write-Warning "Error processing $current"
      $_.Exception.Message | Write-Warning
    }
  }
}
