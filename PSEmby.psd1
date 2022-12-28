@{
  RootModule         = 'PSEmby.psm1'
  ModuleVersion      = '2.0'
  PowerShellVersion  = '6.0'
  GUID               = '7a62f737-f452-4bc9-a289-d15a51f611d8'
  Author             = 'HBuckle'
  RequiredModules    = @(
    'Microsoft.PowerShell.ConsoleGuiTools'
  )
  RequiredAssemblies = @()
  FunctionsToExport  = @(
    'Add-FilmJsonCollections',
    'ConvertFrom-JsonSerialize',
    'ConvertTo-JsonSerialize',
    'Export-DoviRpu',
    'Find-EmbyItem',
    'Find-TmdbFilm',
    'Find-TmdbTvShow',
    'Get-BBFCRating',
    'Get-BDMVIndex',
    'Get-DarAdjustment',
    'Get-DoviInfo',
    'Get-EmbyPerson',
    'Get-FileSafeName',
    'Get-FilmDescription',
    'Get-MediaInfo',
    'Get-TitleCaseString',
    'Get-TmdbFilm',
    'Get-TmdbFilmCredits',
    'Get-TmdbPerson',
    'Get-TmdbTvShow',
    'Get-TmdbTvEpisode',
    'Get-TmdbTvEpisodeGroup',
    'Get-TmdbTvSeason',
    'Get-Ffprobe',
    'Import-SeriesJson',
    'Invoke-Process',
    'Optimize-JPEG',
    'Read-EpisodeJson',
    'Read-FilmJson',
    'Read-PersonJson',
    'Read-SeasonJson',
    'Read-SeriesJson',
    'Save-ChapterImage',
    'Save-YouTubePlaylist',
    'Set-EpisodeJson',
    'Set-FilmJson',
    'Set-FilmJson2',
    'Set-MkvChapterName',
    'Set-MkvProperties',
    'Set-SeasonJson',
    'Set-SeriesJson',
    'Start-EmbyScheduledTask',
    'Update-EmbyPerson',
    'Update-FilmJson'
  )
}
