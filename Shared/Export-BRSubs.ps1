function Export-BRSubs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PathToPlaylist,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$OutputFolder,
    [String]$Language = "English"
  )
  $playlist = Get-Eac3toPlaylist -PathToPlaylist $PathToPlaylist
  $subs = @()
  $subs += $playlist.Tracks | Where-Object { $_.Contains("Subtitle (PGS), $Language") }
  $eac3toargs = @(
    $playlist.Path,
    "1)"
  )
  foreach ($sub in $subs) {
    $trackid = $sub.Split(":")[0]
    if (-not(Test-Path "$OutputFolder\$trackid.sup")) {
      $eac3toargs += "${trackid}:"
      $eac3toargs += "$OutputFolder\$trackid.sup"
    }
  }
  & eac3to $eac3toargs
  foreach ($sub in $subs) {
    $trackid = $sub.Split(":")[0]
    if (-not(Test-Path "$OutputFolder\${trackid}_forced.sup")) {
      Export-ForcedSubs -InputFile "$OutputFolder\$trackid.sup" -OutputFile "$OutputFolder\${trackid}_forced.sup"
    }
  }
}