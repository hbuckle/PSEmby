function Read-EpisodeJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonEpisode])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonEpisode]::new().GetType()
  $episode = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $episode
}
