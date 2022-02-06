function Save-YouTubePlaylist {
  param (
    [string]$Playlist,
    [string]$FilePath
  )
  & ytdlp --dump-json --flat-playlist $Playlist | ConvertFrom-Json -Depth 99 |
    Select-Object -ExpandProperty webpage_url | Out-File $FilePath -Append
}
