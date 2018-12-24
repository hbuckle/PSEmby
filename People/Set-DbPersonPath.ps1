function Set-DbPersonPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [String]$PathToDatabase,
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People"
  )
  $tablename = "MediaItems"
  $persontype = "23"
  try {
    $connection = [System.Data.SQLite.SQLiteConnection]::new("Data Source=${PathToDatabase};Version=3;")
    $connection.Open()
    $connection.EnableExtensions($true)
    $connection.LoadExtension("SQLite.Interop.dll", "sqlite3_fts5_init")
    $peoplequery = "SELECT * FROM ${tablename} WHERE type = '${persontype}' AND ProviderIds IS NOT NULL"
    $peoplecommand = [System.Data.SQLite.SQLiteCommand]::new($peoplequery, $connection)
    $people = $peoplecommand.ExecuteReader()
    while ($people.Read()) {
      Write-Progress -Activity "Updating people" -CurrentOperation $people["Name"]
      $id = $people["Id"]
      Write-Verbose "Set-DbPersonId : id = $id"
      $personname = $people["Name"]
      Write-Verbose "Set-DbPersonId : personname = $personname"
      $tmdbid = ""
      $people["ProviderIds"].Split("|").Foreach({
        if ($_ -match "Tmdb") {
          $tmdbid = $_.Split("=")[1]
          Write-Verbose "Set-DbPersonId : tmdbid = $tmdbid"
        }
      })
      if (-not([String]::IsNullOrEmpty($tmdbid))) {
        $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $personname -PersonId $tmdbid
        if (Test-Path $imagepath) {
          Write-Verbose "Set-DbPersonId : imagepath = $imagepath"
          $item = Get-Item $imagepath
          $ticks = $item.LastWriteTimeUtc.Ticks
          $images = @(
            "%MetadataPath%",
            "People",
            $personname[0],
            "${personname} (${tmdbid})",
            "poster.jpg*${ticks}*Primary*0*0*null"
          ) -join "\" -replace "'", "''"
          if ($people["Images"] -ne $images) {
            Write-Verbose "Set-DbPersonId : images = $images"
            $updateimagequery = "UPDATE ${tablename} SET Images = '${images}' WHERE Id = '${id}'"
            $updateimagecommand = [System.Data.SQLite.SQLiteCommand]::new($updateimagequery, $connection)
            $number = $updateimagecommand.ExecuteNonQuery();
            $updateimagecommand.Dispose()
          }
        }
        $path = @(
          "%MetadataPath%",
          "People",
          $personname[0],
          "${personname} (${tmdbid})"
        ) -join "\" -replace "'", "''"
        if ($people["Path"] -ne $path) {
          Write-Verbose "Set-DbPersonId : path = $path"
          $updatepathquery = "UPDATE ${tablename} SET Path = '${path}' WHERE Id = '${id}'"
          $updatepathcommand = [System.Data.SQLite.SQLiteCommand]::new($updatepathquery, $connection)
          $number = $updatepathcommand.ExecuteNonQuery();
          $updatepathcommand.Dispose()
        }
      }
    }
    Write-Progress -Activity "Updating people" -Completed
  }
  catch {
    throw $_
  }
  finally {
    if ($null -ne $people -and $people.IsClosed -eq $false) {
      $people.Close()
    }
    if ($null -ne $peoplecommand) {
      $peoplecommand.Dispose()
    }
    if ($null -ne $connection -and $connection.State -ne [System.Data.ConnectionState]::Closed) {
      $connection.Close()
    }
  }
}