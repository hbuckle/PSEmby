function ConvertTo-JsonSerialize {
  [CmdletBinding()]
  param (
    [object]$InputObject,
    [string]$Path
  )
  try {
    $stream = [System.IO.File]::OpenWrite($Path)
    $writer = [System.Runtime.Serialization.Json.JsonReaderWriterFactory]::CreateJsonWriter(
      $stream, [System.Text.Encoding]::UTF8, $false, $true, "  "
    )
    $settings = [System.Runtime.Serialization.Json.DataContractJsonSerializerSettings]::new()
    $settings.EmitTypeInformation = [System.Runtime.Serialization.EmitTypeInformation]::Never
    $settings.DateTimeFormat = [System.Runtime.Serialization.DateTimeFormat]::new("yyyy-MM-dd")
    $serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($InputObject.GetType(), $settings)
    $serializer.WriteObject($writer, $InputObject)
  }
  finally {
    if ($null -ne $writer) {
      $writer.Dispose()
    }
    if ($null -ne $stream) {
      $stream.Dispose()
    }
  }
}