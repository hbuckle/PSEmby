function Get-VideoInfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$Path
  )
  & ffprobe -v quiet -print_format json -show_format -show_streams -show_chapters $Path | ConvertFrom-Json
}