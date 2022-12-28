function Set-FilmJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile,

    [Int64]$TmdbId,
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
      }
      else {
        $jsonMovie = [JsonMetadata.Models.JsonMovie]::new()
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId') -and $null -eq $jsonMovie.tmdbid) {
        Write-Error 'TmdbId is required'
      }

      $tmdbFilm = Get-TmdbFilm -Id $TmdbId
      $credits = Get-TmdbFilmCredits -Id $tmdbFilm.id

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
      $jsonMovie.genres = $tmdbFilm.genres | Select-Object -ExpandProperty name
      $jsonMovie.studios = @()
      $jsonMovie.tags = @()
      $jsonMovie.people.Clear()
      $credits.crew | Where-Object job -EQ 'Director' | Add-FilmJsonPerson -Type Director -FilmJson $jsonMovie
      $credits.crew | Where-Object job -In 'Writer', 'Screenplay' | Select-Object -Unique | Add-FilmJsonPerson -Type Writer -FilmJson $jsonMovie
      $credits.cast | Add-FilmJsonPerson -Type Actor -FilmJson $jsonMovie

      if ($PSBoundParameters.ContainsKey('Description')) {
        $jsonMovie.overview = $Description
      }
      if ($PSBoundParameters.ContainsKey('ParentalRating')) {
        $jsonMovie.parentalrating = $ParentalRating
      }

      ConvertTo-JsonSerialize -InputObject $jsonMovie | Set-Content $output -NoNewline

      Add-FilmJsonCollections -InputFile $file.FullName
    }
  }
  end {}
}

function Add-FilmJsonPerson {
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object[]]$Person,

    [ValidateSet('Actor', 'Director', 'Writer')]
    [string]$Type,

    [JsonMetadata.Models.JsonMovie]$FilmJson
  )
  begin {}
  process {
    foreach ($item in $Person) {
      $tmdbPerson = Get-TmdbPerson -Id $item.id
      $jsonPerson = [JsonMetadata.Models.JsonCastCrew]::new()
      $jsonPerson.name = $item.name
      $jsonPerson.type = $Type
      $jsonPerson.tmdbid = $item.id
      $jsonPerson.imdbid = $tmdbPerson.imdb_id
      if ($Type -eq 'Actor') {
        $jsonPerson.role = $item.character
        if ($jsonPerson.role -in 'Composer', 'Director', 'Guest star', 'Producer', 'Writer') {
          Write-Warning "$($FilmJson.title) - $($jsonPerson.name) has role $($jsonPerson.role)"
        }
      }
      $FilmJson.people.Add($jsonPerson)
    }
  }
  end {}
}
