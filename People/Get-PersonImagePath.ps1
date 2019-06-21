function Get-PersonImagePath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$MetadataFolder,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PersonName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$PersonId
  )
  $safeName = $PersonName
  [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {
    $safeName = $safeName.Replace($_.ToString(), "")
  }
  $sortfolder = $safeName[0]
  $personFolder = "$safeName ($PersonId)"
  $outpath = Join-Path -Path $MetadataFolder -ChildPath "${sortfolder}\${personFolder}\poster.jpg"
  return $outpath
}