function Get-TmdbTvShow {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Int64[]]$Id
  )
  begin {}
  process {
    foreach ($item in $Id) {
      Invoke-Tmdb -Path "/tv/${item}"
    }
  }
  end {}
}
