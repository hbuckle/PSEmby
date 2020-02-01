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
    '.\lib\JsonMetadata.dll',
    '.\lib\System.Data.SQLite.dll'
  )
  FunctionsToExport  = @(
    'ConvertFrom-JsonSerialize',
    'ConvertTo-JsonSerialize',
    'Convert-TvSeasonBr',
    'Convert-TvSeasonDvd',
    'Convert-Video',
    'Copy-FileName',
    'Export-BRSubs',
    'Export-ForcedSubs',
    'Export-MediaMonkeyPlaylist',
    'Export-Pgc',
    'Find-EmbyItem',
    'Find-Film',
    'Find-TvShow',
    'Get-DarAdjustment',
    'Get-DVDAudioDelay',
    'Get-Eac3toPlaylist',
    'Get-EmbyPeople',
    'Get-EmbyPerson',
    'Get-EpisodeDescriptionNetflix',
    'Get-FileSafeName',
    'Get-Film',
    'Get-FilmCredits',
    'Get-FilmDescription',
    'Get-FilmMissingDataReport',
    'Get-FilmRating',
    'Get-Gcd',
    'Get-MkvToolnixOption',
    'Get-PersonFolder',
    'Get-Sar',
    'Get-TitleCaseString',
    'Get-TmdbPerson',
    'Get-TvEpisode',
    'Get-TvSeason',
    'Get-TvShow',
    'Get-VideoInfo',
    'Get-VStripPlaylist',
    'Import-TvShowJson',
    'Initialize-TvShowRip',
    'Invoke-SqliteQuery',
    'New-SeasonEpisodeThumbnail',
    'New-SeasonFolder',
    'Optimize-JPEG',
    'Read-EpisodeJson',
    'Read-FilmJson',
    'Read-PersonJson',
    'Remove-MissingPeople',
    'Save-BRPlaylist',
    'Save-ChapterImage',
    'Save-DVDPlaylist',
    'Save-PersonImage',
    'Save-SeasonChapterImage',
    'Save-TmdbPersonImage',
    'Select-ItemFromList',
    'Set-DbPersonPath',
    'Set-EmbyPerson',
    'Set-EpisodeJson',
    'Set-FilmJson',
    'Set-FilmJsonGenre',
    'Set-MkvChapterName',
    'Set-OggChapterName',
    'Set-PersonJson',
    'Set-SeasonEpisodeJson',
    'Set-SeasonEpisodeName',
    'Start-EmbyScheduledTask',
    'Update-EmbyPeople',
    'Update-FilmJson',
    'Update-TmdbPeople'
  )
}
