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
    "Find-Film",
    "Get-Film",
    "Get-FilmCredits",
    "Get-FilmDescription",
    "Get-FilmMissingDataReport",
    "Set-FilmNfo",
    "Update-FilmDescription",
    "Get-PersonImagePath",
    "Get-TmdbPerson",
    "Save-PersonImage",
    "Save-TmdbPersonImage",
    "Set-DbPersonId",
    "Export-ForcedSubs",
    "Get-DarAdjustment",
    "Get-Eac3toPlaylist",
    "Get-TitleCaseString",
    "Get-VideoInfo",
    "Save-BRPlaylist",
    "Select-ItemFromList",
    "Set-MkvChapterName",
    "Set-OggChapterName",
    "Convert-TvSeasonBr",
    "Find-TvShow",
    "Get-EpisodeDescriptionNetflix",
    "Get-TvSeason",
    "Initialize-TvShowRip",
    "Import-TvShowNfo",
    "New-SeasonEpisodeThumbnail",
    "New-SeasonFolder",
    "Set-EpisodeNfo",
    "Set-SeasonEpisodeName",
    "Set-SeasonEpisodeNfo",
    "Set-ToolPaths"
  )
}