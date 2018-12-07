function Get-FilmMissingDataReport {
  [CmdletBinding()]
  param (
    [string]$Path = "\\CRUCIBLE\Films"
  )
  Get-ChildItem -Path $Path -Directory | ForEach-Object {
    $current = $_.FullName
    try {
      $props = [ordered]@{
        Folder    = $_.Name
        FileName  = ""
        Extension = ""
        Poster    = $false
        Backdrop  = 0
        Logo      = $false
        Trailer   = $false
        NFO       = $false
        Width     = 0
        Height    = 0
        Chapters  = $false
        Title     = ""
        SortTitle = ""
        Plot      = $false
        Director  = $false
        Actors    = $false
        Container = ""
      }
      $filmFile = Get-Item "$($_.FullName)\*.mkv"
      $fileInfo = Get-VideoInfo -Path $filmFile.FullName
      $videoStream = $fileInfo.streams | Where-Object { $_.codec_type -like "video" } | Select-Object -First 1

      $props.FileName = $filmFile.BaseName
      $props.Extension = $filmFile.Extension
      $props.Poster = (Test-Path "$($_.FullName)\folder.jpg")
      $props.Backdrop = @(Get-ChildItem $_.FullName -Filter "backdrop*").Count
      $props.Logo = (Test-Path "$($_.FullName)\logo.png")
      $props.Trailer = (Test-Path "$($_.FullName)\Trailers\*.mkv")
      $props.NFO = (Test-Path "$($_.FullName)\*.nfo")
      $props.Height = $videoStream.height
      $props.Width = $videoStream.width
      $props.Chapters = ($fileInfo.Chapters.Count -gt 0)
      if ($props.NFO) {
        $nfoPath = (Resolve-Path "$($_.FullName)\*.nfo").ProviderPath
        $movie = [embymetadata.movie]::Load($nfoPath)
        $props.Title = $movie.title
        $props.SortTitle = $movie.sorttitle
        $props.Plot = (-not([string]::IsNullOrEmpty($movie.plot)))
        $props.Director = ($movie.director.Count -gt 0)
        $props.Actors = ($movie.actor.Count -gt 0)
      }
      if ([bool]($fileInfo.format.PSObject.Properties.Name -match "tags")) {
        $props.Container = $fileInfo.format.tags.encoder
      }
      Write-Output (New-Object PSObject -Property $props)
    }
    catch {
      Write-Warning "Error processing $current"
      $_.Exception.Message | Write-Warning
    }
  }
}