function Read-SeriesJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonSeries])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonSeries]::new().GetType()
  $series = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $series
}
