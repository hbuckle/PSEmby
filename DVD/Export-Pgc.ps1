function Export-Pgc {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$PathToIfo,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [Int]$PgcNumber,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$OutputFolder
  )
  if (-not(Test-Path "$OutputFolder\VideoFile.m2v")) {
    $pgcdemuxargs = @(
      "-pgc",
      $PgcNumber,
      "-m2v",
      "YES",
      "-aud",
      "YES",
      "-sub",
      "YES",
      "-cellt",
      "NO",
      "-title",
      $PathToIfo,
      $OutputFolder
    )
    & pgcdemux $pgcdemuxargs | echo "Wait"
  }
  if (-not(Test-Path "$OutputFolder\chapters.txt")) {
    $item = Get-Item $PathToIfo
    $chaptereditorargs = @(
      $item.DirectoryName,
      $item.BaseName,
      $PgcNumber,
      "--ogg=chapters"
    )
    Push-Location $OutputFolder
    & chaptereditor $chaptereditorargs
    Set-OggChapterName -InputFile "$OutputFolder\chapters.txt"
    Pop-Location
  }
  if (-not(Test-Path "$OutputFolder\video.dgi")) {
    $dgindexnvargs = @(
      "-i",
      "$OutputFolder\VideoFile.m2v",
      "-o",
      "$OutputFolder\video.dgi",
      "-h",
      "-e"
    )
    & dgindexnv $dgindexnvargs | Out-Null
  }
}