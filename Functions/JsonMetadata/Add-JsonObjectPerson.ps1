function Add-JsonObjectPerson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object[]]$Person,

    [ValidateSet('Actor', 'Director', 'Writer')]
    [string]$Type,

    [JsonMetadata.Models.JsonObject]$JsonObject
  )
  begin {}
  process {
    foreach ($item in $Person) {
      $tmdbPerson = Get-TmdbPerson -Id $item.id
      $embyPerson = Get-EmbyPerson -TmdbId $item.id
      $jsonPerson = [JsonMetadata.Models.JsonCastCrew]::new()
      if ($null -ne $embyPerson) {
        $jsonPerson.id = $embyPerson.Id
      }
      $jsonPerson.name = $item.name
      $jsonPerson.type = $Type
      $jsonPerson.tmdbid = $item.id
      $jsonPerson.imdbid = $tmdbPerson.imdb_id
      if ($Type -eq 'Actor') {
        $jsonPerson.role = $item.character
        if ($jsonPerson.role -in 'Composer', 'Director', 'Guest star', 'Producer', 'Writer') {
          Write-Warning "$($JsonObject.title) - $($jsonPerson.name) has role $($jsonPerson.role)"
          $jsonPerson.role = "($($jsonPerson.role))"
        }
      }
      $JsonObject.people.Add($jsonPerson)
    }
  }
  end {}
}
