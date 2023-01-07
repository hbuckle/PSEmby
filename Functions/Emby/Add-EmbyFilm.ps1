function Add-EmbyFilm {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputFile
  )
  $file = Get-Item $InputFile
  Optimize-JPEG -SourceFolder $file.DirectoryName
  $tmdbFilm = Find-TmdbFilm -Title $file.BaseName
  $description = Get-FilmDescription -Title $tmdbFilm.title
  $rating = Get-BBFCRating -Title $tmdbFilm.title
  Set-FilmJson -InputFile $file.FullName -TmdbId $tmdbFilm.id -Description $description -ParentalRating $rating
  Set-MkvProperties -InputFile $file.FullName
  Save-ChapterImage -InputFile $file.FullName
  Start-EmbyScheduledTask -Name 'Scan media library' -Wait
  $output = [System.IO.Path]::ChangeExtension($file.FullName, '.json')
  $filmJson = Read-FilmJson -Path $output
  $filmJson.people | Where-Object id -NE 0 | Update-EmbyPerson
  Start-EmbyScheduledTask -Name 'Set chapter paths'
}
