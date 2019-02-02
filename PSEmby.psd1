@{
  RootModule         = 'PSEmby.psm1'
  ModuleVersion      = '2.0'
  PowerShellVersion  = '6.0'
  GUID               = '7a62f737-f452-4bc9-a289-d15a51f611d8'
  Author             = 'HBuckle'
  RequiredModules    = @(
    'Configuration'
  )
  RequiredAssemblies = @(
    '.\lib\AngleSharp.dll',
    '.\lib\System.Data.SQLite.dll'
  )
  FunctionsToExport  = @(
    'Convert-TvSeasonBr',
    'Convert-TvSeasonDvd',
    'Convert-Video',
    'Copy-FileName',
    'Export-BRSubs',
    'Export-ForcedSubs',
    'Export-Pgc',
    'Find-Film',
    'Find-TvShow',
    'Get-DarAdjustment',
    'Get-DVDAudioDelay',
    'Get-Eac3toPlaylist',
    'Get-EmbyPeople',
    'Get-EmbyPerson',
    'Get-EpisodeDescriptionNetflix',
    'Get-Film',
    'Get-FilmCredits',
    'Get-FilmDescription',
    'Get-FilmMissingDataReport',
    'Get-Gcd',
    'Get-MkvToolnixOption',
    'Get-PersonImagePath',
    'Get-Sar',
    'Get-TitleCaseString',
    'Get-TmdbPerson',
    'Get-TvEpisode',
    'Get-TvSeason',
    'Get-TvShow',
    'Get-VideoInfo',
    'Get-VStripPlaylist',
    'Import-TvShowJson',
    'Import-TvShowNfo',
    'Initialize-TvShowRip',
    'New-SeasonEpisodeThumbnail',
    'New-SeasonFolder',
    'Save-BRPlaylist',
    'Save-DVDPlaylist',
    'Save-PersonImage',
    'Save-TmdbPersonImage',
    'Select-ItemFromList',
    'Set-DbPersonPath',
    'Set-EmbyPerson',
    'Set-EpisodeJson',
    'Set-EpisodeNfo',
    'Set-FilmJson',
    'Set-FilmJsonGenre',
    'Set-FilmNfo',
    'Set-MkvChapterName',
    'Set-OggChapterName',
    'Set-SeasonEpisodeJson',
    'Set-SeasonEpisodeName',
    'Set-SeasonEpisodeNfo',
    'Start-EmbyScheduledTask',
    'Update-EmbyPeople',
    'Update-FilmDescription'
  )
}
