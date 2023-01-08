function Get-TmdbTvEpisode {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'ShowId')]
    [ValidateNotNullOrEmpty()]
    [Int64]$Id,

    [Parameter(Mandatory = $true, ParameterSetName = 'ShowId')]
    [ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [int[]]$Number,

    [Parameter(Mandatory = $true, ParameterSetName = 'EpisodeGroup')]
    [string]$EpisodeGroupId,

    [Parameter(Mandatory = $true, ParameterSetName = 'EpisodeGroup')]
    [string]$EpisodeGroupSeasonId
  )
  begin {}
  process {
    foreach ($item in $Number) {
      if ($PSCmdlet.ParameterSetName -eq 'ShowId') {
        Invoke-Tmdb -Path "/tv/${Id}/season/${SeasonNumber}/episode/${item}" -Query @{append_to_response = 'external_ids'}
      }
      if ($PSCmdlet.ParameterSetName -eq 'EpisodeGroup') {
        $episodeGroup = Get-TmdbTvEpisodeGroup -Id $EpisodeGroupId
        $season = $episodeGroup.groups | Where-Object id -EQ $EpisodeGroupSeasonId
        $episode = $season.episodes | Where-Object { $_.order + 1 -EQ $item }
        $fullEpisode = Invoke-Tmdb -Path "/tv/$($episode.show_id)/season/$($episode.season_number)/episode/$($episode.episode_number)" -Query @{append_to_response = 'external_ids'}
        if ($fullEpisode.id -ne $episode.id) {
          Write-Error 'Something bad'
        }
        else {
          $fullEpisode.episode_number = $episode.order + 1
          $fullEpisode.season_number = $season.order
          Write-Output $fullEpisode
        }
      }
    }
  }
  end {}
}
