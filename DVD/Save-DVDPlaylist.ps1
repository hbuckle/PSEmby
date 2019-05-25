function Save-DVDPlaylist {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Path
  )
  if (-not(Test-Path "$Path\VIDEO_TS")) {
    throw "$Path is not a DVD folder"
  }
  Get-ChildItem "$Path\VIDEO_TS\*" -Exclude "VIDEO_TS.IFO" -Include "*.IFO" | ForEach-Object {
    $outputvstrip = "$Path\$($_.Name).json"
    if (-not(Test-Path $outputvstrip)) {
      $playlist = Get-VStripPlaylist -PathToPlaylist $_.FullName
      $playlist | ConvertTo-Json | Set-Content $outputvstrip -Encoding utf8NoBOM
    }
  }
}