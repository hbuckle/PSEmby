function Set-FilmJsonGenre {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToFilm
  )
  $file = Get-Item $PathToFilm
  Write-Verbose "Set-FilmJsonGenre : PathToFilm = $PathToFilm"
  $output = $file.DirectoryName + "\" + $file.BaseName + ".json"
  if (Test-Path $output) {
    $movie = Get-Content $output -Raw | ConvertFrom-Json -AsHashtable
    if ([String]::IsNullOrEmpty($movie["tmdbid"])) {
      Write-Warning "Set-FilmJsonGenre : tmdbid not found in ${output}"
      return
    }
    $film = Get-Film -ID $movie["tmdbid"]
    $movie["genres"] = @()
    foreach ($genre in $film["genres"]) {
      $movie["genres"] += $genre["name"]
    }
    $movie | ConvertTo-Json -Depth 99 | Set-Content $output -Encoding utf8NoBOM
  }
  else {
    Write-Warning "Set-FilmJsonGenre : json file ${output} not found"
    return
  }
}