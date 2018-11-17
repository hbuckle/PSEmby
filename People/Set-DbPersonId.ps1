function Set-DbPersonId {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [String]$PathToDatabase
  )
  $tablename = "MediaItems"
  $persontype = "23"
  try {
    $connection = [System.Data.SQLite.SQLiteConnection]::new("Data Source=${PathToDatabase};Version=3;")
    $connection.Open()
    $connection.EnableExtensions($true)
    $connection.LoadExtension("SQLite.Interop.dll", "sqlite3_fts5_init")
    $peoplequery = "SELECT * FROM ${tablename} WHERE type = '${persontype}' AND Name LIKE '% (%)' AND ProviderIds IS NULL"
    $peoplecommand = [System.Data.SQLite.SQLiteCommand]::new($peoplequery, $connection)
    $people = $peoplecommand.ExecuteReader()
    while ($people.Read()) {
      Write-Progress -Activity "Updating people" -CurrentOperation $people["Name"]
      $matches = ($people["Name"] | Select-String -Pattern "\((\d+)\)").Matches
      if ($matches.Count -eq 1) {
        $tmdbid = $matches[0].Value.Trim("(",")")
        $providerId = "Tmdb=$tmdbid"
        $guidstring = ($people["guid"].ToByteArray() | ForEach-Object ToString X2) -join ''
        $updatequery = "UPDATE ${tablename} SET ProviderIds = '${providerid}' WHERE guid = X'${guidstring}'"
        $updatecommand = [System.Data.SQLite.SQLiteCommand]::new($updatequery, $connection)
        $number = $updatecommand.ExecuteNonQuery();
        $updatecommand.Dispose()
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