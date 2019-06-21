function Remove-MissingPeople {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$MetadataFolder = "\\CRUCIBLE\Metadata\metadata\People",
    [string[]]$JsonPath = @("\\CRUCIBLE\Films", "\\CRUCIBLE\tv")
  )
  $people = @()
  Get-ChildItem $JsonPath -Recurse -Include "*.json" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw | ConvertFrom-Json -Depth 99 -AsHashtable
    foreach ($person in $content["people"]) {
      $imagepath = Get-PersonImagePath -MetadataFolder $MetadataFolder -PersonName $person["name"] -PersonId $person["tmdbid"]
      $people += Split-Path $imagepath -Parent
    }
  }
  $peoplefolders = @()
  Get-ChildItem $MetadataFolder -Directory | ForEach-Object {
    $peoplefolders += Get-ChildItem $_.FullName -Directory
  }
  foreach ($folder in $peoplefolders) {
    if ($people -notcontains $folder) {
      Remove-Item $folder.FullName -Force -Recurse
    }
  }
}