function Read-SeriesJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonSeries])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonSeries]
  $series = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $series
}
