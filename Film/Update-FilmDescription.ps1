function Update-FilmDescription {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PathToNfo
  )
  $movie = [embymetadata.movie]::Load($PathToNfo)
  $description = Get-FilmDescription -Title $movie.title
  $movie.plot = $description
  $movie.Save($PathToNfo)
}