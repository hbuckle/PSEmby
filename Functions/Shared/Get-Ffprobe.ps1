function Get-Ffprobe {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile,

    [switch]$AsHashtable
  )
  begin {}
  process {
    foreach ($item in $InputFile) {
      & ffprobe -v quiet -print_format json -show_format -show_streams -show_chapters $item |
        ConvertFrom-Json -Depth 99 -AsHashtable:$($AsHashtable.ToBool())
    }
  }
  end {}
}
