function Save-SeasonChapterImage {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$SourceFolder
  )
  Get-ChildItem -LiteralPath $SourceFolder -Filter "*.mkv" | ForEach-Object {
    $chapterpath = Join-Path $_.DirectoryName "\Chapters\$($_.BaseName)"
    Save-ChapterImage -InputFile $_.FullName -OutputPath $chapterpath
  }
  $chaptersfolder = Join-Path $SourceFolder "Chapters"
  if (Test-Path $chaptersfolder) {
    $ignore = Join-Path $chaptersfolder ".ignore"
    if (-not(Test-Path $ignore)) {
      $null = New-Item $ignore -ItemType File
    }
  }
}