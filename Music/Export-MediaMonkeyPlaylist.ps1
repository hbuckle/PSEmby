function Export-MediaMonkeyPlaylist {
  [CmdletBinding()]
  param (
    [string]$PlaylistName = "Running",
    [string]$OutputPath = "\\CRUCIBLE\Audio\Playlists\Running.m3u8"
  )
  $tempfile = "$env:TEMP\$((New-Guid).Guid).DB"
  Copy-Item "$env:appdata\MediaMonkey\MM.DB" -Destination $tempfile
  $connection = [System.Data.SQLite.SQLiteConnection]::new("Data Source=${tempfile};Version=3;")
  try {
    $connection.Open()
    $connection.EnableExtensions($true)
    $connection.LoadExtension("SQLite.Interop.dll", "sqlite3_fts5_init")
    $playlistquery = "SELECT * FROM Playlists WHERE PlaylistName = '${PlaylistName}' COLLATE NOCASE"
    $playlist = Invoke-SqliteQuery -Connection $connection -Query $playlistquery
    $idsquery = "SELECT IDSong FROM PlaylistSongs WHERE IdPlaylist = $($playlist['IDPlaylist'])"
    $ids = Invoke-SqliteQuery -Connection $connection -Query $idsquery
    $result = @()
    $count = 1
    foreach ($id in $ids) {
      Write-Progress -Activity "Getting songs" -PercentComplete ($count / $ids.Count * 100)
      $songquery = "SELECT SongPath FROM Songs WHERE ID = $($id['IDSong'])"
      $song = Invoke-SqliteQuery -Connection $connection -Query $songquery
      $path = $song["SongPath"]
      if ($path.ToLower().StartsWith("\\crucible\music")) {
        $path = $path.Replace("\\CRUCIBLE\Music", "\\CRUCIBLE\Audio\Music")
        $result += $path
      }
      $count++
    }
    $result | Sort-Object | Set-Content $OutputPath -Encoding utf8NoBOM
  }
  catch {
    throw $_
  }
  finally {
    if ($null -ne $connection -and $connection.State -ne [System.Data.ConnectionState]::Closed) {
      $connection.Close()
    }
    if (Test-Path $tempfile) {
      Remove-Item $tempfile -Force
    }
  }
}