class AudioTrack {
  AudioTrack() { }
  [string]$Path
  [string]$Language
  [string]$Delay
}

class Subtitle {
  Subtitle() { }
  [string]$Path
  [string]$Language
  [bool]$Default
  [bool]$Forced
}

function Get-MkvToolnixOption {
  [CmdletBinding()]
  param (
    [string]$Output,
    [string]$Video,
    [string]$AspectRatio,
    [string]$FPS,
    [AudioTrack[]]$Audio,
    [Subtitle[]]$Subtitle = @(),
    [string]$Chapters
  )
  $options = @(
    "--ui-language",
    "en",
    "--output",
    $Output,
    "--language",
    "0:eng",
    "--aspect-ratio",
    "0:${AspectRatio}",
    "--default-duration",
    "0:${FPS}",
    "(",
    $Video,
    ")"
  )
  foreach ($track in $Audio) {
    $options += @(
      "--language",
      "0:$($track.Language)",
      "--sync",
      "0:$($track.Delay)",
      "(",
      $track.Path,
      ")"
    )
  }
  foreach ($track in $Subtitle) {
    $default = if ($track.Default) { "yes" } else { "no" }
    $forced = if ($track.Forced) { "yes" } else { "no" }
    $options += @(
      "--language",
      "0:$($track.Language)",
      "--default-track",
      "0:${default}",
      "--forced-track",
      "0:${forced}",
      "(",
      $track.Path,
      ")"
    )
  }
  if (-not([string]::IsNullOrEmpty($Chapters))) {
    $options += @(
      "--chapter-language",
      "und",
      "--chapters",
      $Chapters
    )
  }
  $options += "--track-order"
  $trackscount = 1 + $Audio.Count
  $trackorder = @()
  for ($i = 0; $i -lt $trackscount; $i++) {
    $trackorder += "${i}:0"
  }
  $options += ($trackorder -join ",")
  return ($options | ConvertTo-Json -Depth 99)
}