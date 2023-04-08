function Set-EpisodeJson {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile
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
        $jsonEpisode = Read-EpisodeJson -Path $output
        $currentString = [System.IO.File]::ReadAllText($output)
      }
      else {
        $jsonEpisode = [JsonMetadata.Models.JsonEpisode]::new()
        $currentString = '{}'
      }

      $jsonSeries = Import-SeriesJson $file.Directory.FullName
      if ($null -eq $jsonSeries) {
        Write-Error "File '$($file.Directory.Parent.FullName)\tvshow.json' was not found"
      }

      $jsonSeason = Read-SeasonJson (Join-Path $file.Directory.FullName 'season.json')

      Write-Progress -Activity 'Set-EpisodeJson' -Status $file.FullName

      if ($file.Directory.Name -eq 'Specials') {
        # do things
      }
      else {
        [int]$seasonNumber = $file.Name.Substring(1, 2)
        [int]$episodeNumber = $file.Name.Substring(4, 2)
        $fileName = $file.BaseName.Substring(9, $file.BaseName.Length - 9)
        if ([string]::IsNullOrEmpty($jsonSeason.tmdbepisodegroupid)) {
          $tmdbEpisode = Get-TmdbTvEpisode -Id $jsonSeries.tmdbid -SeasonNumber $seasonNumber -Number $episodeNumber
        }
        else {
          $segments = $jsonSeason.tmdbepisodegroupid.Split('/')
          $tmdbEpisode = Get-TmdbTvEpisode -EpisodeGroupId $segments[2] -EpisodeGroupSeasonId $segments[4] -Number $episodeNumber
        }
        if ([string]::IsNullOrEmpty($jsonEpisode.customfields['title'])) {
          $jsonEpisode.title = Get-TitleCaseString $tmdbEpisode.name
        }
        else {
          $jsonEpisode.title = $jsonEpisode.customfields['title']
        }
        $safeName = Get-FileSafeName $jsonEpisode.title
        if ($safeName -cne $fileName) {
          Write-Warning "Input file '$($file.FullName)' does not match name '${safeName}'"
        }
        $jsonEpisode.sorttitle = Get-SortTitleString $jsonEpisode.title
        $jsonEpisode.seasonnumber = $seasonNumber
        $jsonEpisode.episodenumber = $episodeNumber
        $jsonEpisode.communityrating = $null
        $jsonEpisode.releasedate = [datetime]::ParseExact(
          $tmdbEpisode.air_date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture
        )
        $jsonEpisode.year = $jsonEpisode.releasedate.Year
        $jsonEpisode.parentalrating = [string]::Empty
        $jsonEpisode.customrating = [string]::Empty
        $jsonEpisode.tvdbid = [string]::Empty
        $jsonEpisode.imdbid = $tmdbEpisode.external_ids.imdb_id
        $jsonEpisode.genres = $jsonSeries.genres
        $jsonEpisode.studios = @()
        $jsonEpisode.tags = @()
        $jsonEpisode.lockdata = $true
        $jsonEpisode.people.Clear()
        $tmdbEpisode.crew | Where-Object job -EQ 'Director' |
          Add-JsonObjectPerson -Type Director -JsonObject $jsonEpisode
        $jsonEpisode.overview = Get-StandardString -InputString $jsonEpisode.overview

        $outputString = ConvertTo-JsonSerialize -InputObject $jsonEpisode
        $hasDifference = $false
        $diffResult = Get-Dyff -ReferenceString $currentString -DifferenceString $outputString -Result ([ref]$hasDifference)
        if ($hasDifference) {
          if ($PSCmdlet.ShouldProcess("Performing the operation `"Set Content`" on target `"Path: ${output}`" with content:`n$diffResult", 'Set Content', $output)) {
            $outputString | Set-Content $output -NoNewline
          }
        }
      }
    }
  }
  end {
    Write-Progress -Activity 'Set-EpisodeJson' -Completed
  }
}
