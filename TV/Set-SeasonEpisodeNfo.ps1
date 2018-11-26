function Set-SeasonEpisodeNfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ShowName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage,
    [ValidateSet("Netflix")]
    [string]$DescriptionSource,
    [string]$DescriptionId
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $params = @{
      PathToEpisode  = $_.FullName
      ShowName       = $ShowName
      SeasonNumber   = $SeasonNumber
      MetadataFolder = $MetadataFolder
    }
    if ($null -ne $DescriptionSource) {
      $params["DescriptionSource"] = $DescriptionSource
      $params["DescriptionId"] = $DescriptionId
    }
    Set-EpisodeNfo @params -RedownloadPersonImage:$RedownloadPersonImage
  }
}