function Get-TmdbTvEpisodeGroup {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Id
  )
  begin {}
  process {
    Invoke-Tmdb -Path "/tv/episode_group/${Id}"
  }
  end {}
}
