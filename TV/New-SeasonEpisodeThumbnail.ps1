function New-SeasonEpisodeThumbnail {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $env:outfile = $_.FullName.Replace(".mkv", "-thumb.jpg")
    if (-not(Test-Path $env:outfile)) {
      $fileInfo = & ffprobe -v quiet -print_format json -show_format -show_streams $_.FullName | ConvertFrom-Json
      [int]$duration = $fileInfo.format.duration
      $time = Get-Random -Minimum 180 -Maximum ($duration - 180)
      $width = Get-DarAdjustment $_.FullName
      $env:width = $width.ToString()
      $videoStream = $fileInfo.streams | Where-Object { $_.codec_type -like "video" } | Select-Object -First 1
      $height = $videoStream.height
      $env:height = $height
      $eap = $ErrorActionPreference
      $ErrorActionPreference = "SilentlyContinue"
      & ffmpeg -ss $time -i $_.FullName --% -v error -qscale:v 2 -vframes 1 -vf scale=%width%:%height% "%outfile%"   | Out-Null
      $ErrorActionPreference = $eap
    }
  }
}