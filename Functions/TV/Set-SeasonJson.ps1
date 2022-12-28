function Set-SeasonJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFolder
  )
  begin {}
  process {
    foreach ($item in $InputFolder) {
      $folder = Get-Item $item
      $output = Join-Path $folder.FullName 'season.json'
      if (Test-Path $output) {
        $jsonSeason = Read-SeasonJson -Path $output
      }
      else {
        $jsonSeason = [JsonMetadata.Models.JsonSeason]::new()
      }

      $jsonSeries = Import-SeriesJson $folder.FullName
      if ($null -eq $jsonSeries) {
        Write-Error "File '$($folder.Parent.FullName)\tvshow.json' was not found"
      }

      if ($folder.Name -eq 'Specials') {
        # do things
      }
      else {
        [int]$seasonNumber = $folder.Name.Substring($folder.Name.Length - 2, 2)
        $tmdbSeason = Get-TmdbTvSeason -Id $jsonSeries.tmdbid -Number $seasonNumber
        $jsonSeason.title = '{0} {1}' -f $folder.Name.Substring(0, $folder.Name.Length - 3), $seasonNumber
        $jsonSeason.sorttitle = [string]::Empty
        $jsonSeason.seasonnumber = $seasonNumber
        $jsonSeason.communityrating = $null
        $jsonSeason.releasedate = [datetime]::ParseExact(
          $tmdbSeason.air_date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture
        )
        $jsonSeason.year = $jsonSeason.releasedate.Year
        $jsonSeason.parentalrating = [string]::Empty
        $jsonSeason.customrating = [string]::Empty
        $jsonSeason.tvdbid = [string]::Empty
        $jsonSeason.genres = $jsonSeries.genres
        $jsonSeason.people = @()
        $jsonSeason.studios = @()
        $jsonSeason.tags = @()
        $jsonSeason.lockdata = $true

        ConvertTo-JsonSerialize -InputObject $jsonSeason | Set-Content $output -NoNewline
      }
    }
  }
  end {}
}
