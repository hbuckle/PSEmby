function Select-ItemFromList {
  [CmdletBinding()]
  param (
    [String]$Title = "",
    [Array]$List = @(),
    [Array]$Properties = @()
  )
  if ($List.Count -eq 0) {
    return $null
  }
  $selector = @()
  $count = 1
  foreach ($item in $List) {
    $obj = [Ordered]@{ }
    $obj["number"] = $count
    if ($Properties.Count -gt 0) {
      foreach ($prop in $Properties) {
        $obj[$prop] = $item.$prop
      }
    }
    else {
      $obj["value"] = $item
    }
    $selector += New-Object -TypeName PSObject -Property $obj
    $count++
  }
  Write-Host $Title
  $selector | Format-Table -AutoSize -Wrap | Out-Host
  $choice = Read-Host "Number"
  $index = [int]$choice - 1
  if ($choice -eq 0) {
    return $null
  }
  else {
    return $List[$index]
  }
}