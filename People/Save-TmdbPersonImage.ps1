function Save-TmdbPersonImage {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$MetadataFolder,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PersonName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PersonId,
    [switch]$Overwrite
  )
  $outfile = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $PersonName -PersonId $PersonId
  if (-not(Test-Path (Split-Path $outfile))) {
    $null = New-Item -ItemType Directory -Path (Split-Path $outfile)
  }
  if (-not(Test-Path $outfile) -or $Overwrite) {
    $person = Get-TmdbPerson -PersonId $PersonId
    if ($null -ne $person["profile_path"]) {
      $imageUrl = "https://image.tmdb.org/t/p/original$($person[`"profile_path`"])"
      Write-Verbose "Save-TmdbPersonImage : imageurl = $imageUrl"
      Write-Verbose "Save-TmdbPersonImage : outfile = $outfile"
      $client = [System.Net.WebClient]::new()
      $client.DownloadFile($imageUrl, $outfile)
      $client.Dispose()
    }
  }
}