function ConvertFrom-JsonSerialize {
  [CmdletBinding()]
  param (
    [string]$Path,
    [type]$Type
  )
  $string = Get-Content $Path -Raw
  $options = [System.Text.Json.JsonSerializerOptions]::new()
  $options.Converters.Add(
    [JsonMetadata.Models.DateTimeConverter]::new('yyyy-MM-dd')
  )
  try {
    [System.Text.Json.JsonSerializer]::Deserialize($string, $Type)
  }
  catch {
    throw "Error deserializing ${Path} : $($_.Exception.Message)"
  }
}
