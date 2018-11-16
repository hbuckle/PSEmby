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
    [switch]$RedownloadPersonImage
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    Set-EpisodeNfo -PathToEpisode $_.FullName -ShowName $ShowName -SeasonNumber $SeasonNumber -MetadataFolder $MetadataFolder -RedownloadPersonImage:$RedownloadPersonImage
  }
}