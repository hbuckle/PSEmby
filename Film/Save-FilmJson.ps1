function Save-FilmJson {
  [CmdletBinding()]
  param (
    [JsonMetadata.Models.JsonMovie]$InputObject,  
    [string]$Path
  )
  ConvertTo-JsonSerialize -InputObject $InputObject -Path $Path
}