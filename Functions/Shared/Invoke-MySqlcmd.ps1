function Invoke-MySqlcmd {
  [CmdletBinding()]
  param (
    [string]$Server = 'Crucible.home.crucible.org.uk',
    [string]$Database = 'myvideos131',
    [string]$Username = 'kodi',
    [string]$Password = 'kodi',
    [string]$Query
  )
  $builder = [MySqlConnector.MySqlConnectionStringBuilder]::new()
  $builder.Server = $Server
  $builder.Database = $Database
  $builder.UserID = $Username
  $builder.Password = $Password
  $builder.SslMode = 'Disabled'
  $connection = [MySqlConnector.MySqlConnection]::new($builder.ConnectionString)
  try {
    $connection.Open()
    $command = $Connection.CreateCommand()
    $command.CommandText = $Query
    $reader = $command.ExecuteReader()
    $table = [System.Data.DataTable]::new()
    $table.Load($reader)
    $reader.Dispose()
    return $table
  }
  finally {
    $connection.Dispose()
  }
}
