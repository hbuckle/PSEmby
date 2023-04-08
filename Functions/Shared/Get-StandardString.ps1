function Get-StandardString {
  [CmdletBinding()]
  param (
    [string]$InputString
  )
  $InputString = $InputString.Replace('—', '-')
  $InputString = $InputString.Replace('–', '-')
  $InputString = $InputString.Replace("`’", "'")
  $InputString = $InputString.Replace('“', '"')
  $InputString = $InputString.Replace('”', '"')
  $InputString = $InputString.Replace('&amp;', '&')

  Write-Output $InputString
}
