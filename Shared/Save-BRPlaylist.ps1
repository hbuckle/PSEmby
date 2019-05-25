function Save-BRPlaylist {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Path
  )
  if (-not(Test-Path "$Path\BDMV\PLAYLIST")) {
    throw "$Path is not a Blu-Ray folder"
  }
  Get-ChildItem "$Path\BDMV\PLAYLIST\*" | ForEach-Object {
    $outputeac3to = "$Path\$($_.Name).json"
    if (-not(Test-Path $outputeac3to)) {
      $playlist = Get-Eac3toPlaylist -PathToPlaylist $_.FullName
      $playlist | ConvertTo-Json | Set-Content $outputeac3to -Encoding utf8NoBOM
    }
    $outputmediainfo = "$Path\$($_.Name).xml"
    if (-not(Test-Path $outputmediainfo)) {
      & mediainfo --Output=XML $_.FullName | Set-Content $outputmediainfo -Encoding utf8NoBOM
    }
  }
}