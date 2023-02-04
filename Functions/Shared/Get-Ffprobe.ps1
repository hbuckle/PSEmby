function Get-Ffprobe {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputFile,

    [switch]$AsHashtable
  )
  & ffprobe -v quiet -print_format json -show_format -show_streams -show_chapters $InputFile |
    ConvertFrom-Json -Depth 99 -AsHashtable:$($AsHashtable.ToBool())
}
