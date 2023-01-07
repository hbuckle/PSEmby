function Find-EmbyItem {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )
  Invoke-Emby -Path 'Items' -Query @{
    Recursive = $true; NameStartsWith = $Name; Fields = 'People,Genres'
  } | Select-Object -ExpandProperty 'Items' | Write-Output
}
