function Invoke-SqliteQuery {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [System.Data.SQLite.SQLiteConnection]$Connection,
    [Parameter(Mandatory = $true)]
    [string]$Query
  )
  if ($Connection.State -ne [System.Data.ConnectionState]::Open) {
    throw "Connection is not open"
  }
  try {
    $command = [System.Data.SQLite.SQLiteCommand]::new($Query, $Connection)
    $reader = $command.ExecuteReader()
    $schema = $reader.GetSchemaTable()
    $results = @()
    while ($reader.Read()) {
      $result = @{ }
      foreach ($row in $schema.Rows) {
        $result[$row.ColumnName] = $reader[$row.ColumnName]
      }
      $results += $result
    }
    Write-Output $results
  }
  catch {
    throw $_
  }
  finally {
    if ($null -ne $reader -and $reader.IsClosed -eq $false) {
      $reader.Close()
    }
    if ($null -ne $command) {
      $command.Dispose()
    }
  }
}