function Get-FileSafeName {
  param (
    [string]$Name
  )
  $result = $Name.Replace(":", ";")
  foreach ($invalidChar in [System.IO.Path]::GetInvalidFileNameChars()) {
    $result = $result.Replace($invalidChar.ToString(), "")
  }
  Write-Output $result
}