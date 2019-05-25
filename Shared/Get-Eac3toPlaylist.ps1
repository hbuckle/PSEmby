function Get-Eac3toPlaylist {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToPlaylist
  )
  $output = & eac3to $PathToPlaylist --% 1)
  $output = $output -replace "`b", ""
  $details = @($output[0].Replace("-", "").Trim() -split ", ")
  $playlist = @{
    "Path"    = $PathToPlaylist
    "Details" = $output[0].Replace("-", "").Trim()
    "Tracks"  = @($output | Select-Object -Skip 1 | ForEach-Object {
        if ($_.Trim() -match '\d+: .*') {
          $_.Trim()
        }
      }
    )
  }
  foreach ($detail in $details) {
    try {
      $playlist["Length"] = ([timespan]$detail).ToString()
      break
    }
    catch {
      $playlist["Length"] = ""
    }
  }
  $object = New-Object -TypeName PSObject -Property $playlist
  Write-Output $object
}