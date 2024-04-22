function Sync-KodiMovie {
  [CmdletBinding()]
  param (
    [int]$Id
  )
  Invoke-Kodi -Method 'VideoLibrary.RefreshMovie' -Parameters @{movieid = $Id; ignorenfo = $false} |
    Out-Null
}
