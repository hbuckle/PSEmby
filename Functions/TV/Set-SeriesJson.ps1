function Set-SeriesJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFolder,

    [Int64]$TmdbId
  )
  begin {}
  process {
    foreach ($item in $InputFolder) {
      $output = Join-Path $item 'tvshow.json'
      if (Test-Path $output) {
        $jsonSeries = Read-SeriesJson -Path $output
      }
      else {
        $jsonSeries = [JsonMetadata.Models.JsonSeries]::new()
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId') -and $null -eq $jsonSeries.tmdbid) {
        Write-Error 'TmdbId is required'
      }
      if ($PSBoundParameters.ContainsKey('TmdbId')) {
        $jsonSeries.tmdbid = $TmdbId
      }

      $tmdbShow = Get-TmdbTvShow -Id $jsonSeries.tmdbid

      $jsonSeries.title = Get-TitleCaseString $tmdbShow.name
      $jsonSeries.sorttitle = Split-Path $item -Leaf
      $jsonSeries.tmdbid = $tmdbShow.id
      $jsonSeries.imdbid = $tmdbShow.external_ids.imdb_id
      $jsonSeries.genres = $tmdbShow.genres | Select-Object -ExpandProperty name
      $jsonSeries.releasedate = [datetime]::ParseExact(
        $tmdbShow.first_air_date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture
      )
      $jsonSeries.year = $jsonSeries.releasedate.Year
      if ($tmdbShow.status -in 'Ended', 'Cancelled') {
        $jsonSeries.status = 'Ended'
        $jsonSeries.enddate = [datetime]::ParseExact(
          $tmdbShow.last_air_date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture
        )
      }
      else {
        $tmdbShow.status = 'Continuing'
        $jsonSeries.enddate = $null
      }
      $jsonSeries.displayorder = 'Aired'
      $jsonSeries.lockdata = $true

      ConvertTo-JsonSerialize -InputObject $jsonSeries | Set-Content $output -NoNewline
    }
  }
  end {}
}
