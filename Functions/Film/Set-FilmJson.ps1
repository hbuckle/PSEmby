function Set-FilmJson {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile,

    [Int64]$TmdbId,
    [ValidateSet('Action', 'Drama', 'Comedy', 'Fantasy', 'Horror', 'Romance', 'Science Fiction', 'Thriller', 'War', 'Western')]
    [string[]]$Genre,
    [string]$Description,
    [string]$ParentalRating
  )
  begin {}
  process {
    foreach ($item in $InputFile) {
      $file = Get-Item $item
      if ($file.Extension -ne '.mkv') {
        Write-Error "Input file '$($file.FullName)' was not in the correct format"
      }
      $output = [System.IO.Path]::ChangeExtension($file.FullName, '.json')

      if (Test-Path $output) {
        $jsonMovie = Read-FilmJson -Path $output
        $currentString = [System.IO.File]::ReadAllText($output)
      }
      else {
        $jsonMovie = [JsonMetadata.Models.JsonMovie]::new()
        $currentString = '{}'
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId') -and $null -eq $jsonMovie.tmdbid) {
        Write-Error 'TmdbId is required'
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId')) {
        $TmdbId = $jsonMovie.tmdbid
      }
      Write-Progress -Activity 'Set-FilmJson' -Status $file.FullName

      $tmdbFilm = Get-TmdbFilm -Id $TmdbId -Verbose:$false
      $credits = Get-TmdbFilmCredits -Id $tmdbFilm.id -Verbose:$false

      $jsonMovie.title = Get-TitleCaseString $tmdbFilm.title
      $jsonMovie.originaltitle = ''
      $jsonMovie.tagline = ''
      $jsonMovie.customrating = ''
      $jsonMovie.communityrating = $null
      $jsonMovie.releasedate = $null
      $jsonMovie.sorttitle = $file.Directory.Name
      $jsonMovie.year = ([datetime]$tmdbFilm.release_date).Year
      $jsonMovie.imdbid = $tmdbFilm.imdb_id
      $jsonMovie.tmdbid = $tmdbFilm.id
      $jsonMovie.tmdbcollectionid = $tmdbFilm.belongs_to_collection?.id
      $jsonMovie.lockdata = $true
      if ($PSBoundParameters.ContainsKey('Genre')) {
        $jsonMovie.genres = $Genre
      }
      $jsonMovie.studios = @()
      $jsonMovie.tags = @()
      $jsonMovie.people.Clear()
      $credits.crew | Where-Object job -EQ 'Director' | Add-JsonObjectPerson -Type Director -JsonObject $jsonMovie -Verbose:$false
      $credits.crew | Where-Object job -In 'Writer', 'Screenplay' | Select-Object -Unique | Add-JsonObjectPerson -Type Writer -JsonObject $jsonMovie -Verbose:$false
      $credits.cast | Add-JsonObjectPerson -Type Actor -JsonObject $jsonMovie -Verbose:$false

      if ($PSBoundParameters.ContainsKey('Description')) {
        $jsonMovie.overview = $Description
      }
      if ($PSBoundParameters.ContainsKey('ParentalRating')) {
        $jsonMovie.parentalrating = $ParentalRating
      }
      $jsonMovie.overview = Get-StandardString -InputString $jsonMovie.overview

      $outputString = ConvertTo-JsonSerialize -InputObject $jsonMovie
      $hasDifference = $false
      $diffResult = Get-Dyff -ReferenceString $currentString -DifferenceString $outputString -Result ([ref]$hasDifference)
      if ($hasDifference) {
        if ($PSCmdlet.ShouldProcess("Performing the operation `"Set Content`" on target `"Path: ${output}`" with content:`n$diffResult", 'Set Content', $output)) {
          $outputString | Set-Content $output -NoNewline
        }
      }

      Add-FilmJsonCollection -InputFile $file.FullName
    }
  }
  end {
    Write-Progress -Activity 'Set-FilmJson' -Completed
  }
}
