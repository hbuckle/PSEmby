function Update-FilmJson {
  [CmdletBinding()]
  param (
    [string]$Path = '\\CRUCIBLE\Films'
  )
  $files = @()
  $files += Get-ChildItem -Path $Path -Filter '*.mkv' -Recurse -Depth 1
  $count = 1
  $files | ForEach-Object {
    Write-Progress -Activity 'Updating film metadata' -CurrentOperation $_.Name -PercentComplete ($count / $files.Count * 100)
    Set-FilmJson -PathToFilm $_.FullName
    $count++
  }
}
