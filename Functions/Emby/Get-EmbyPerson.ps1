function Get-EmbyPerson {
  [CmdletBinding(DefaultParameterSetName = 'List')]
  param (
    [Parameter(ParameterSetName = 'Name')]
    [string]$Name,

    [Parameter(ParameterSetName = 'Id')]
    [string]$Id,

    [Parameter(ParameterSetName = 'TmdbId')]
    [Int64]$TmdbId
  )
  if ($PSCmdlet.ParameterSetName -eq 'Name') {
    Invoke-Emby -Path 'Items' -Query @{
      IncludeItemTypes = 'Person'; Recursive = $true; NameStartsWith = $Name
    } | Select-Object -ExpandProperty 'Items' | Write-Output
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'Id') {
    Invoke-Emby -Path "Items/${Id}"
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'TmdbId') {
    Invoke-Emby -Path 'Items' -Query @{
      IncludeItemTypes = 'Person'; Recursive = $true; NameStartsWith = $Name; AnyProviderIdEquals = "Tmdb.${TmdbId}"
    } | Select-Object -ExpandProperty 'Items' | Write-Output
  }
  else {
    Invoke-Emby -Path 'Persons' | Select-Object -ExpandProperty 'Items' | Write-Output
  }
}
