function Get-DVDAudioDelay {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$PathToPlaylist,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$PathToPgcDemuxLog
  )
  $playlist = Get-Content $PathToPlaylist -Raw | ConvertFrom-Json
  $log = Get-Content $PathToPgcDemuxLog
  $delays = @()
  for ($i = $log.IndexOf("[Audio Delays]") + 1; $i -lt $log.IndexOf("[Subs Streams]"); $i++) {
    $delays += $log[$i].Split("=")[1]
  }
  for ($j = 0; $j -lt $playlist.Audio.Count; $j++) {
    $playlist.Audio[$j].Delay = $delays[$j]
  }
  $playlist | ConvertTo-Json | Set-Content $PathToPlaylist -Encoding Ascii
}