function Read-SeasonJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonSeason])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonSeason]
  $season = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $season
}
