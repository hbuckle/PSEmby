function Add-EmbyFilm {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputFile,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Action', 'Drama', 'Comedy', 'Fantasy', 'Horror', 'Romance', 'Science Fiction', 'Thriller', 'War', 'Western')]
    [string[]]$Genre
  )
  $file = Get-Item $InputFile
  Optimize-JPEG -SourceFolder $file.DirectoryName
  $tmdbFilm = Find-TmdbFilm -Title $file.BaseName
  $description = Get-FilmDescription -Title $tmdbFilm.title
  $rating = Get-BBFCRating -Title $tmdbFilm.title
  Set-FilmJson -InputFile $file.FullName -TmdbId $tmdbFilm.id -Description $description -ParentalRating $rating -Genre $Genre
  Set-FilmNfo -InputFile $file.FullName -TmdbId $tmdbFilm.id -Description $description -ParentalRating $rating -Genre $Genre
  Set-MkvProperties -InputFile $file.FullName
  Save-ChapterImage -InputFile $file.FullName
  Start-EmbyScheduledTask -Name 'Scan media library' -Wait
  $output = [System.IO.Path]::ChangeExtension($file.FullName, '.json')
  $filmJson = Read-FilmJson -Path $output
  $filmJson.people | Where-Object id -NE 0 | Sync-EmbyPerson
  Start-EmbyScheduledTask -Name 'Set chapter paths'
}
