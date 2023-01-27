function Get-StringDiff {
  [CmdletBinding()]
  param (
    [string]$ReferenceString,
    [string]$DifferenceString,
    [ref]$Result
  )
  $tempReference = (New-TemporaryFile -WhatIf:$false -Confirm:$false).FullName
  $tempDifference = (New-TemporaryFile -WhatIf:$false -Confirm:$false).FullName
  try {
    [System.IO.File]::WriteAllText($tempReference, $ReferenceString)
    [System.IO.File]::WriteAllText($tempDifference, $DifferenceString)
    $diffResult = & linuxdiff --side-by-side --suppress-common-lines --ignore-trailing-space --expand-tabs --strip-trailing-cr $tempReference $tempDifference
    $output = $diffResult -join "`n"
    if ([string]::IsNullOrWhiteSpace($output)) {
      $Result.Value = $false
      Write-Output '  **Content is identical**'
    }
    else {
      $Result.Value = $true
      Write-Output $output
    }
  }
  finally {
    Remove-Item $tempReference -Force -WhatIf:$false -Confirm:$false
    Remove-Item $tempDifference -Force -WhatIf:$false -Confirm:$false
  }
}
