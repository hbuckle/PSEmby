function Set-PersonJson {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = "InputObject")]
    [JsonMetadata.Models.JsonPerson]$InputObject,
    [Parameter(Mandatory = $true, ParameterSetName = "TmdbId")]
    [int]$TmdbId,
    [string]$Path
  )
  $folder = Split-Path $Path -Parent
  if (-not(Test-Path $folder)) {
    $null = New-Item -Path $folder -ItemType "Directory" -Force
  }
  if ($PSBoundParameters.ContainsKey("TmdbId")) {
    $person = Get-TmdbPerson -PersonId $TmdbId
    $InputObject = [JsonMetadata.Models.JsonPerson]::new()
    $InputObject.tmdbid = $TmdbId.ToString()
    $InputObject.name = $person.name
    $InputObject.overview = $person.biography
    $InputObject.birthdate = ($null -ne $person.birthday ?
      [datetime]::ParseExact($person.birthday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture) :
      $null
    )
    $InputObject.birthyear = ($null -ne $person.birthday ?
      [datetime]::ParseExact($person.birthday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture).Year :
      $null
    )
    $InputObject.placeofbirth = $person.place_of_birth
    $InputObject.deathdate = ($null -ne $person.deathday ?
      [datetime]::ParseExact($person.deathday, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture) :
      $null
    )
    $InputObject.imdbid = $person.imdb_id
    $InputObject.tags = @()
    $InputObject.images = @()
    $InputObject.lockdata = $true
    $embymatches = @()
    $embymatches += Get-EmbyPerson -Name $person.name
    if ($embymatches.Count -eq 1) {
      $InputObject.id = $embymatches[0].Id
    }
    if ($null -ne $person["profile_path"]) {
      $imagepath = Join-Path (Split-Path $Path -Parent) "poster.jpg"
      $imageuri = "https://image.tmdb.org/t/p/original" + $person["profile_path"]
      if (Test-Path $imagepath) {
        $remoteimage = Invoke-WebRequest $imageuri -Method "Head"
        $localimage = Get-Item $imagepath
        if ($localimage.Length -ne [int64]($remoteimage.Headers["Content-Length"][0])) {
          Invoke-RestMethod $imageuri -Method "Get" -OutFile $imagepath
        }
      }
      else {
        Invoke-RestMethod $imageuri -Method "Get" -OutFile $imagepath
      }
      $jsonimage = [JsonMetadata.Models.JsonImage]::new()
      $jsonimage.type = "Primary"
      $jsonimage.path = $imagepath
      $InputObject.images.Add($jsonimage)
    }
  }
  ConvertTo-JsonSerialize -InputObject $InputObject | Set-Content -Path $Path -Encoding utf8NoBOM
}