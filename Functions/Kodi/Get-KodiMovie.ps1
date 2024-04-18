function Get-KodiMovie {
  [CmdletBinding(DefaultParameterSetName = 'List')]
  param (
    [Parameter(ParameterSetName = 'Id')]
    [int]$Id
  )
  if ($PSCmdlet.ParameterSetName -eq 'Id') {
    $jsonrpc = Invoke-Kodi
    Invoke-Kodi -Method 'VideoLibrary.GetMovieDetails' -Parameters @{movieid = $Id; properties = $jsonrpc.types.'Video.Fields.Movie'.items.enums} |
      Select-Object -ExpandProperty 'moviedetails' | Write-Output
  }
  else {
    Invoke-Kodi -Method 'VideoLibrary.GetMovies' -Parameters @{properties = @(
        'title', 'sorttitle', 'file'
      )
    } | Select-Object -ExpandProperty 'movies' | Write-Output
  }
}
