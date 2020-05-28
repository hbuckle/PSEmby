function Update-TmdbPeople {
  [CmdletBinding()]
  param (
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People"
  )
  throw "Not Tested Yet"
  $files = Get-ChildItem $MetadataFolder -Recurse -Include "*.json"
  foreach ($file in $files) {
    try {
      $personjson = Read-PersonJson -Path $file.FullName
      $person = Get-TmdbPerson -PersonId $personjson.tmdbid
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
      if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Warning "Person $($personjson.name) ($($personjson.tmdbid)) not found, removing"
        Remove-Item $file.DirectoryName -Recurse -Force
      }
      continue
    }
    catch {
      Write-Warning $_.Exception.Message
      continue
    }
    if ($personjson.name -ne $person.name) {
      Write-Warning "Name mismatch $($file.FullName) : $($person.name) => $($personjson.name)"
      continue
    }
    $personjson.overview = $person.biography
    $personjson.birthdate = ($null -ne $person.birthday ?
      [datetime]::ParseExact($person.birthday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture) :
      $null
    )
    $personjson.birthyear = ($null -ne $person.birthday ?
      [datetime]::ParseExact($person.birthday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture).Year :
      $null
    )
    $personjson.placeofbirth = $person.place_of_birth
    $personjson.deathdate = ($null -ne $person.deathday ?
      [datetime]::ParseExact($person.deathday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture) :
      $null
    )
    $personjson.imdbid = $person.imdb_id
    $personjson.tags = @()
    $personjson.lockdata = $true
    Set-PersonJson -InputObject $personjson -Path $file.FullName
  }
}
