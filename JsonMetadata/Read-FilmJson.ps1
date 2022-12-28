function Read-FilmJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonMovie])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonMovie]::new().GetType()
  $movie = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $movie
}
