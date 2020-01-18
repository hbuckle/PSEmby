function Get-FileSafeName {
  param (
    [string]$Name
  )
  return $Name.Replace(":", ";").Replace("?", "").Replace("/", "_")
}