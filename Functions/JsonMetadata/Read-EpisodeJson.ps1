function Read-EpisodeJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonEpisode])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonEpisode]
  $episode = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $episode
}
