function ConvertFrom-JsonSerialize {
  [CmdletBinding()]
  param (
    [string]$Path,
    [type]$Type
  )
  $string = Get-Content $Path -Raw
  $options = [System.Text.Json.JsonSerializerOptions]::new()
  $options.Converters.Add(
    [JsonMetadata.Models.DateTimeConverter]::new("yyyy-MM-dd")
  )
  [System.Text.Json.JsonSerializer]::Deserialize($string, $Type)
}