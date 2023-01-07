function Read-PersonJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonPerson])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonPerson]
  $person = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $person
}
