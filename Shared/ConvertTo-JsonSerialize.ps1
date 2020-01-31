function ConvertTo-JsonSerialize {
  [CmdletBinding()]
  param (
    [object]$InputObject
  )
  $options = [System.Text.Json.JsonSerializerOptions]::new()
  $options.WriteIndented = $true
  $options.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
  $options.Converters.Add(
    [JsonMetadata.Models.DateTimeConverter]::new("yyyy-MM-dd")
  )
  $json = [System.Text.Json.JsonSerializer]::Serialize($InputObject, $InputObject.GetType(), $options)
  Write-Output $json
}