function Get-PersonImagePath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$MetadataFolder,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PersonName,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$PersonId
  )
  $sortfolder = $PersonName[0]
  $safeName = $PersonName.Replace('"', " ")
  $personFolder = "$safeName ($PersonId)"
  $outpath = Join-Path -Path $MetadataFolder -ChildPath "${sortfolder}\${personFolder}\poster.jpg"
  Write-Verbose "Get-PersonImagePath : outpath = $outpath"
  return $outpath
}