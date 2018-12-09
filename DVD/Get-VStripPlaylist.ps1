function Get-VStripPlaylist {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PathToPlaylist
  )
  $file = Get-Item $PathToPlaylist
  $vob = $PathToPlaylist.Replace($file.Extension, ".VOB")
  if (Test-Path $vob) {
    $output = & vstrip "$vob" -i"$PathToPlaylist"
    $playlist = @{
      "Path"  = $PathToPlaylist
      "Name"  = $file.Name
      "Video" = $output[$output.IndexOf("Video:") + 1].Trim()
      "Audio" = @()
      "PGC"   = @()
    }
    if ($output.Contains("SubPicture:")) {
      $separator = "SubPicture:"
    }
    else {
      $separator = "Program Chain(s):"
    }
    for ($i = $output.IndexOf("Audio:") + 1; $i -lt $output.IndexOf($separator); $i++) {
      $playlist.Audio += @{
        Name = $output[$i].Trim()
        Delay = "0"
      }
    }
    for ($i = $output.IndexOf("Program Chain(s):") + 1; $i -lt $output.IndexOf("Scanning for stream id's, press control-c to quit..."); $i++) {
      $number = [int]($output[$i].Split(". ")[0]) + 1
      $playlist.PGC += @{
        Number = $number
        Detail = $output[$i].Split(". ")[1].Trim()
      }
    }
    $object = New-Object -TypeName PSObject -Property $playlist
    Write-Output $object
  }
}