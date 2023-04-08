function Get-MediaInfo {
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
      & mediainfo --Full --Output=JSON $InputFile |
        ConvertFrom-Json -Depth 99 -AsHashtable:$($AsHashtable.ToBool())
    }
  }
  end {}
}
