@{
  RootModule = 'PSEmby.psm1'
  ModuleVersion = '2.0'
  GUID = '7a62f737-f452-4bc9-a289-d15a51f611d8'
  Author = 'HBuckle'
  RequiredAssemblies = @(
    '.\lib\AngleSharp.dll',
    '.\lib\System.Data.SQLite.dll'
  )
  FunctionsToExport = @(
    'Update-FilmDescription',
    'Set-SeasonEpisodeName',
    'Set-SeasonEpisodeNfo',
    'Set-EpisodeNfo',
    'New-SeasonEpisodeThumbnail',
    'New-SeasonFolder',
    'Set-FilmNfo',
    'Find-Film',
    'Get-FilmDescription',
    'Get-FilmMissingDataReport',
    'Save-PersonImage',
    'Set-DbPersonId',
    'Initialize-TvShowRip',
    'Convert-TvSeasonBr',
    'Export-ForcedSubs',
    'Get-Eac3toPlaylist',
    'Get-VideoInfo'
  )
}