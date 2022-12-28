function Get-TmdbTvEpisode {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Int64]$Id,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [int[]]$Number
  )
  begin {}
  process {
    foreach ($item in $Number) {
      Invoke-Tmdb -Path "/tv/${Id}/season/${SeasonNumber}/episode/${item}" -Query @{append_to_response = 'external_ids'}
    }
  }
  end {}
}
