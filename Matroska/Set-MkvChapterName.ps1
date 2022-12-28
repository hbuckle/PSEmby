function Set-MkvChapterName {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $InputFile
  )
  $file = Get-Item $InputFile
  $tempfile = New-TemporaryFile
  & mkvextract $file.FullName chapters $tempfile.FullName
  if ((Get-Item $tempfile.FullName).Length -gt 0) {
    $chapters = [Mkv.Chapters]::Load($tempfile.FullName)
    foreach ($edition in $chapters.EditionEntry) {
      $count = 1
      $hiddencount = 1
      foreach ($chapter in $edition.ChapterAtom) {
        $chapter.ChapterFlagEnabled = '1'
        $chapter.ChapterDisplay[0].ChapterLanguage = 'und'
        switch ($chapter.ChapterFlagHidden) {
          '0' {
            $name = "Chapter ${count}"
            $count++
          }
          '1' {
            $name = "Hidden Chapter ${hiddencount}"
            $hiddencount++
          }
          $null {
            $chapter.ChapterFlagHidden = '0'
            $name = "Chapter ${count}"
            $count++
          }
          Default {
            throw "Invalid ChapterFlagHidden value $($chapter.ChapterFlagHidden) for $($chapter.ChapterUID)"
          }
        }
        $chapter.ChapterDisplay[0].ChapterString = $name
      }
    }
    $chapters.Save($tempfile.FullName)
    $null = & mkvpropedit -c $tempfile.FullName $file.FullName
  }
  Remove-Item $tempfile.FullName -Force
}
