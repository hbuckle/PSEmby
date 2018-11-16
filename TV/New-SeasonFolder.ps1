function New-SeasonFolder {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [int]$SeasonNumber,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [int]$NumberOfEpisodes
  )
  foreach ($count in 1..$NumberOfEpisodes) {
    $episode = "S$($SeasonNumber.ToString().PadLeft(2,'0'))E$($count.ToString().PadLeft(2,'0'))"
    $folder = Join-Path $SourceFolder $episode
    if (-not(Test-Path $folder)) {
      New-Item $folder -ItemType Directory | Out-Null
      $episode = @{
        "complete" = $false
        "mpls"     = ""
      }
      $episode | ConvertTo-Json | Set-Content "$folder\episode.json" -Encoding Ascii
    }
  }
}