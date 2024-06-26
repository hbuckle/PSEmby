function Get-TmdbFilmReleaseDate {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Int64[]]$Id
  )
  begin {}
  process {
    foreach ($item in $Id) {
      Invoke-Tmdb -Path "/movie/${item}/release_dates" | Select-Object -ExpandProperty 'results'
    }
  }
  end {}
}
