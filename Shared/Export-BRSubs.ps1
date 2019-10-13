function Export-BRSubs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$InputFile,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$OutputFolder,
    [String]$Language = "English"
  )
  $item = Get-Item $InputFile
  switch ($item.Extension) {
    ".mpls" {
      $playlist = Get-Eac3toPlaylist -PathToPlaylist $InputFile
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
    ".mkv" {
      $info = & mkvmerge -J $InputFile | ConvertFrom-Json -AsHashtable
      $subs = @()
      $subs += $info["tracks"] | Where-Object codec -eq "HDMV PGS"
      foreach ($sub in $subs) {
        $output = "$OutputFolder\$($item.BaseName)-$($sub['id']).sup"
        $output_forced = "$OutputFolder\$($item.BaseName)-$($sub['id'])_forced.sup"
        & mkvextract tracks $InputFile "$($sub['id']):${output}"
        if (-not(Test-Path $output_forced)) {
          Export-ForcedSubs -InputFile $output -OutputFile $output_forced
        }
      }
    }
    Default {
      Write-Warning "Unsupported file type $($item.Extension)"
    }
  }
}