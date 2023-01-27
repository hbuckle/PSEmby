function Set-MkvChapterName {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $InputFile
  )
  $file = Get-Item $InputFile
  $tempfile = New-TemporaryFile -WhatIf:$false -Confirm:$false
  & mkvextract $file.FullName chapters $tempfile.FullName
  if ((Get-Item $tempfile.FullName).Length -gt 0) {
    $currentString = [System.IO.File]::ReadAllText($tempfile.FullName)
    [xml]$chapters = $currentString
    foreach ($edition in $chapters.Chapters.EditionEntry) {
      $count = 1
      $hiddencount = 1
      foreach ($chapter in $edition.ChapterAtom) {
        $chapter.ChapterFlagEnabled = '1'
        $chapter.ChapterDisplay.ChapterLanguage = 'und'
        $chapter.ChapterDisplay.ChapLanguageIETF = 'und'
        switch ($chapter.ChapterFlagHidden) {
          '0' {
            $name = "Chapter ${count}"
            $count++
            break
          }
          '1' {
            $name = "Hidden Chapter ${hiddencount}"
            $hiddencount++
            break
          }
          $null {
            $chapter.ChapterFlagHidden = '0'
            $name = "Chapter ${count}"
            $count++
            break
          }
          Default {
            throw "Invalid ChapterFlagHidden value $($chapter.ChapterFlagHidden) for $($chapter.ChapterUID)"
          }
        }
        $chapter.ChapterDisplay.ChapterString = $name
      }
    }
    $chapters.Save($tempfile.FullName)
    $outputString = [System.IO.File]::ReadAllText($tempfile.FullName)
    $hasDifference = $false
    $diffResult = Get-StringDiff -ReferenceString $currentString -DifferenceString $outputString -Result ([ref]$hasDifference)
    if ($hasDifference) {
      if ($PSCmdlet.ShouldProcess("Performing the operation `"Set Chapters`" on target `"Path: $($file.FullName)`" with content:`n$diffResult", 'Set Chapters', $file.FullName)) {
        $null = & mkvpropedit -c $tempfile.FullName $file.FullName
      }
    }
  }
  Remove-Item $tempfile.FullName -Force -WhatIf:$false -Confirm:$false
}
