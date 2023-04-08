function Get-Dyff {
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
    $diffResult = & dyff -t on -c on -w -1 between --set-exit-code --omit-header $tempReference $tempDifference
    $output = $diffResult -join "`n"
    if ($LASTEXITCODE -eq 0) {
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
