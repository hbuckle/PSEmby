function Read-PersonJson {
  [CmdletBinding()]
  [OutputType([JsonMetadata.Models.JsonPerson])]
  param (
    [string]$Path
  )
  $type = [JsonMetadata.Models.JsonPerson]::new().GetType()
  $person = ConvertFrom-JsonSerialize -Path $Path -Type $type
  return $person
}
