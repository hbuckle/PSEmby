function Save-ChapterImage {
  [CmdletBinding()]
  param (
    [string]$InputFile,
    [string]$OutputPath = ((Get-Item $InputFile).DirectoryName + '\Chapters\' + (Get-Item $InputFile).BaseName)
  )
  $ffprobe = Get-Ffprobe -InputFile $InputFile -AsHashtable
  if ($ffprobe['chapters'].Count -gt 0) {
    if (-not(Test-Path $OutputPath)) {
      $null = New-Item $OutputPath -ItemType Directory
    }
    $ignore = Join-Path $OutputPath '.ignore'
    if (-not(Test-Path $ignore)) {
      $null = New-Item $ignore -ItemType File
    }
    $parent_ignore = Join-Path (Split-Path $OutputPath -Parent) '.ignore'
    if (-not(Test-Path $parent_ignore)) {
      $null = New-Item $parent_ignore -ItemType File
    }
  }
  foreach ($chapter in $ffprobe['chapters']) {
    $time = $chapter['start_time']
    # $name = $chapter["tags"]["title"]
    $output = Join-Path $OutputPath "${time}.jpg"
    if (-not(Test-Path $output)) {
      $video = $ffprobe['streams'] | Where-Object { $_['codec_type'] -eq 'video' }
      $hdr = $video['color_space'] -match 'bt2020'
      $sar = $video['sample_aspect_ratio']
      $commands = @(
        '-v',
        'quiet',
        '-ss',
        $time,
        '-i',
        $InputFile,
        '-frames:v',
        '1'
      )
      if ($hdr) {
        $commands += @(
          '-vf',
          'zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p'
        )
      }
      if ($sar -ne '1:1') {
        $width = Get-DarAdjustment -PathToFile $InputFile
        $height = $video['height']
        $commands += @(
          '-vf',
          "scale=${width}x${height}"
        )
      }
      $commands += $output
      & ffmpeg $commands
    }
  }
  if (Test-Path $OutputPath) {
    Optimize-JPEG -SourceFolder $OutputPath
  }
}
