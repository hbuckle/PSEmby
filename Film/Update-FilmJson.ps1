function Update-FilmJson {
  [CmdletBinding()]
  param (
    [string]$Path = "\\CRUCIBLE\Films"
  )
  $jsons = @()
  $jsons += Get-ChildItem -Path $Path -Include "*.json" -Recurse
  $count = 1
  $jsons | ForEach-Object {
    Write-Progress -Activity "Updating film metadata" -CurrentOperation $_.Name -PercentComplete ($count / $jsons.Count * 100)
    Set-FilmJson -PathToFilm $_.FullName
    $count++
  }
}