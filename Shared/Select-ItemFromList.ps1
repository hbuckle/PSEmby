function Select-ItemFromList {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [Array]$List,
    [Array]$Properties = @()
  )
  $selector = @()
  $count = 1
  foreach ($item in $List) {
    $obj = [Ordered]@{}
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