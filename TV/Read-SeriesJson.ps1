function Read-SeriesJson {
  [CmdletBinding()]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonSeries]::new().GetType()
  $series = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $series
}