function Get-SortTitleString {
  [CmdletBinding()]
  param (
    [string]$InputString
  )
  if ($InputString.StartsWith('The ')) {
    Write-Output ($InputString.Remove(0, 4) + ', The')
  }
  elseif ($InputString.StartsWith('An ')) {
    Write-Output ($InputString.Remove(0, 3) + ', An')
  }
  elseif ($InputString.StartsWith('A ')) {
    Write-Output ($InputString.Remove(0, 2) + ', A')
  }
  else {
    Write-Output $InputString
  }
}
