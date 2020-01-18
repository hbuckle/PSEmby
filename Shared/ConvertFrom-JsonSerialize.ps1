function ConvertFrom-JsonSerialize {
  [CmdletBinding()]
  param (
    [string]$Path,
    [type]$Type
  )
  try {
    $stream = [System.IO.File]::OpenRead($Path)
    $reader = [System.Runtime.Serialization.Json.JsonReaderWriterFactory]::CreateJsonReader(
      $stream, [System.Text.Encoding]::UTF8, [System.Xml.XmlDictionaryReaderQuotas]::Max, $null
    )
    $settings = [System.Runtime.Serialization.Json.DataContractJsonSerializerSettings]::new()
    $settings.EmitTypeInformation = [System.Runtime.Serialization.EmitTypeInformation]::Never
    $settings.DateTimeFormat = [System.Runtime.Serialization.DateTimeFormat]::new("yyyy-MM-dd")
    $serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($Type, $settings)
    $result = $serializer.ReadObject($reader)
    return $result
  }
  finally {
    if ($null -ne $reader) {
      $reader.Dispose()
    }
    if ($null -ne $stream) {
      $stream.Dispose()
    }
  }
}