function Get-TvSeason {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = "Id")]
    [ValidateNotNullOrEmpty()]
    [int]$ShowId,

    [Parameter(Mandatory = $true, ParameterSetName = "Id")]
    [ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,

    [Parameter(Mandatory = $true, ParameterSetName = "EpisodeGroup")]
    [ValidateNotNullOrEmpty()]
    [string]$EpisodeGroupId,

    [Parameter(Mandatory = $true, ParameterSetName = "EpisodeGroup")]
    [ValidateNotNullOrEmpty()]
    [string]$SeasonId
  )
  $client = [tmdbclient]::new($Script:tmdb_api_key)
  switch ($PSCmdlet.ParameterSetName) {
    "Id" {
      return $client.gettvseason($ShowId, $SeasonNumber)
    }
    "EpisodeGroup" {
      $group = $client.gettvepisodegroup($EpisodeGroupId)
      $season = $group["groups"] | Where-Object id -eq $SeasonId
      if ($null -eq $season) {
        throw "Episode group $EpisodeGroupId/group/$SeasonId not found"
      }
      return $season
    }
    Default { }
  }
}
