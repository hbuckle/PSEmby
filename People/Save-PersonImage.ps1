function Save-PersonImage {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$SourceFolder,
    [ValidateNotNullOrEmpty()]
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [switch]$Overwrite
  )
  $nfoFiles = @(Get-ChildItem -Path $SourceFolder -Recurse -Include "*.nfo")
  $people = @()
  $count = 1
  foreach ($nfoFile in $nfoFiles) {
    Write-Progress -Activity "Scanning for people" -CurrentOperation $nfoFile.FullName -PercentComplete ($count / $nfoFiles.Count * 100)
    [xml]$content = Get-Content $nfoFile.FullName
    foreach ($actor in $content.DocumentElement.SelectNodes("actor")) {
      $people += $actor.name
    }
    foreach ($director in $content.DocumentElement.SelectNodes("director")) {
      $people += $director.'#text'
    }
    $count++
  }
  Write-Progress -Activity "Scanning for people" -Completed
  $count = 1
  $unique = $people | Select-Object -Unique
  foreach ($person in $unique) {
    Write-Progress -Activity "Downloading images" -CurrentOperation $person -PercentComplete ($count / $people.Count * 100)
    $matches = ($person | Select-String -Pattern "\((\d+)\)").Matches
    if ($matches.Count -eq 1) {
      $tmdbid = $matches[0].Value.Trim("(", ")")
      $name = $person.Replace("($tmdbid)", "").Trim()
      try {
        Save-TmdbPersonImage -MetadataFolder $MetadataFolder -PersonName $name -PersonId $tmdbid -Overwrite:$Overwrite
      }
      catch {
        Write-Warning "Error saving image for $person"
        Write-Warning $_.Exception.Message
      }
    }
    else {
      Write-Warning "Could not match TmdbId for $person"
    }
    $count++
  }
  Write-Progress -Activity "Downloading images" -Completed
}