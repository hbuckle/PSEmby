@{
  RootModule         = 'PSEmby.psm1'
  ModuleVersion      = '2.0'
  PowerShellVersion  = '6.0'
  GUID               = '7a62f737-f452-4bc9-a289-d15a51f611d8'
  Author             = 'HBuckle'
  RequiredModules    = @()
  RequiredAssemblies = @(
    '.\lib\AngleSharp.dll',
    '.\lib\JsonMetadata.dll',
    '.\lib\System.Data.SQLite.dll'
  )
  FunctionsToExport  = @(
    'Convert-TvSeasonBr',
    'Convert-TvSeasonDvd',
    'Convert-Video',
    'ConvertFrom-JsonSerialize',
    'ConvertTo-JsonSerialize',
    'Export-BRSubs',
    'Export-ForcedSubs',
    'Export-MediaMonkeyPlaylist',
    'Export-Pgc',
    'Export-RPU',
    'Find-EmbyItem',
    'Find-Film',
    'Find-TvShow',
    'Get-BBFCRating',
    'Get-BDMVIndex',
    'Get-DarAdjustment',
    'Get-DoviInfo',
    'Get-DVDAudioDelay',
    'Get-Eac3toPlaylist',
    'Get-EmbyPerson',
    'Get-EpisodeDescriptionNetflix',
    'Get-FileSafeName',
    'Get-Film',
    'Get-FilmCredits',
    'Get-FilmDescription',
    'Get-FilmMissingDataReport',
    'Get-MediaInfo',
    'Get-MkvToolnixOption',
    'Get-Sar',
    'Get-TitleCaseString',
    'Get-TmdbPerson',
    'Get-TvEpisode',
    'Get-TvSeason',
    'Get-TvShow',
    'Get-VideoInfo',
    'Get-VStripPlaylist',
    'Import-SeriesJson',
    'Initialize-TvShowRip',
    'Invoke-Process',
    'Invoke-SqliteQuery',
    'New-SeasonEpisodeThumbnail',
    'New-SeasonFolder',
    'Optimize-JPEG',
    'Read-EpisodeJson',
    'Read-FilmJson',
    'Read-PersonJson',
    'Read-SeasonJson',
    'Read-SeriesJson',
    'Remove-MissingPeople',
    'Save-BRPlaylist',
    'Save-ChapterImage',
    'Save-DVDPlaylist',
    'Save-SeasonChapterImage',
    'Save-YouTubePlaylist',
    'Select-ItemFromList',
    'Set-DbPersonPath',
    'Set-EpisodeJson',
    'Set-FilmJson',
    'Set-MkvChapterName',
    'Set-MkvProperties',
    'Set-OggChapterName',
    'Set-PersonJson',
    'Set-SeasonEpisodeJson',
    'Set-SeasonEpisodeName',
    'Set-SeasonJson',
    'Set-SeriesJson',
    'Start-EmbyScheduledTask',
    'Update-EmbyPerson',
    'Update-FilmJson',
    'Update-TmdbPeople'
  )
}
