function Get-MediaInfo {
  [CmdletBinding()]
  param(
    [string]$InputFile,
    [switch]$AsHashtable
  )
  & mediainfo --Output=JSON $InputFile | ConvertFrom-Json -Depth 99 -AsHashtable:$($AsHashtable.ToBool())
}
