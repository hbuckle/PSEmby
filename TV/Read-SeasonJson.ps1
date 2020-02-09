function Read-SeasonJson {
  [CmdletBinding()]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonSeason]::new().GetType()
  $season = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $season
}