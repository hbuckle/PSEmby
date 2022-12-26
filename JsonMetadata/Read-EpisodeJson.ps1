function Read-EpisodeJson {
  [CmdletBinding()]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonEpisode]::new().GetType()
  $episode = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $episode
}
