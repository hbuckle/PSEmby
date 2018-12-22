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
    "Set-FilmJson",
    "Set-FilmJsonGenre",
    "Set-FilmNfo",
    "Update-FilmDescription",
    "Get-People",
    "Get-PersonImagePath",
    "Get-TmdbPerson",
    "Save-PersonImage",
    "Save-TmdbPersonImage",
    "Set-DbPersonImagePath",
    "Export-BRSubs",
    "Export-ForcedSubs",
    "Get-DarAdjustment",
    "Get-Eac3toPlaylist",
    "Get-TitleCaseString",
    "Get-VideoInfo",
    "Get-VStripPlaylist",
    "Save-BRPlaylist",
    "Save-DVDPlaylist",
    "Select-ItemFromList",
    "Set-MkvChapterName",
    "Set-OggChapterName",
    "Convert-TvSeasonBr",
    "Convert-TvSeasonDvd",
    "Find-TvShow",
    "Get-EpisodeDescriptionNetflix",
    "Get-TvSeason",
    "Initialize-TvShowRip",
    "Import-TvShowNfo",
    "New-SeasonEpisodeThumbnail",
    "New-SeasonFolder",
    "Set-EpisodeJson",
    "Set-EpisodeNfo",
    "Set-SeasonEpisodeName",
    "Set-SeasonEpisodeNfo",
    "Set-ToolPaths"
  )
}