function Set-SeasonEpisodeJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [string]$ShowName,
    [int]$SeasonNumber,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$RedownloadPersonImage,
    [switch]$ReleaseDate
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $params = @{
      PathToEpisode  = $_.FullName
      MetadataFolder = $MetadataFolder
      ShowName       = $ShowName
      SeasonNumber   = $SeasonNumber
    }
    Set-EpisodeJson @params -RedownloadPersonImage:$RedownloadPersonImage -ReleaseDate:$ReleaseDate
  }
}