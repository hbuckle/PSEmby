function Get-DarAdjustment {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFile
  )
  $fileInfo = & ffprobe -v quiet -print_format json -show_format -show_streams $PathToFile | ConvertFrom-Json
  $fileInfo | ConvertTo-Json -Depth 100 | Write-Verbose
  $videoStream = $fileInfo.streams | Where-Object { $_.codec_type -like "video" } | Select-Object -First 1
  $sar = $videoStream.sample_aspect_ratio
  $dar = $videoStream.display_aspect_ratio
  $width = $videoStream.width

  Write-Verbose $sar
  Write-Verbose $dar
  Write-Verbose $width

  if (-not($sar.Contains("1:1"))) {
    $sarValues = $sar.Replace("sample_aspect_ratio=", "").Split(":")
    $adjustment = ([int]$sarValues[0] / [int]$sarValues[1]) * $width
    [int]$adjustment = [Math]::Round(
      ($adjustment / [double]16),
      [System.MidpointRounding]::AwayFromZero
    ) * 16

    return $adjustment
  }
  else
  { return $width }
}