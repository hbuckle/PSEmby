function Get-TmdbTvSeason {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Int64]$Id,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [int]$Number
  )
  begin {}
  process {
    Invoke-Tmdb -Path "/tv/${Id}/season/${Number}"
  }
  end {}
}
