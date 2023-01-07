function Update-EmbyPerson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [int[]]$Id
  )
  begin {}
  process {
    foreach ($item in $Id) {
      $person = Get-EmbyPerson -Id $item
      Write-Progress -Activity 'Update-EmbyPerson' -Status $person.Name
      $null = Invoke-Emby -Path "Items/${item}/Refresh" -Query @{
        Recursive           = $true
        ImageRefreshMode    = 'FullRefresh'
        MetadataRefreshMode = 'FullRefresh'
        ReplaceAllImages    = $true
        ReplaceAllMetadata  = $true
      } -Method Post
    }
  }
  end {
    Write-Progress -Activity 'Update-EmbyPerson' -Completed
  }
}
