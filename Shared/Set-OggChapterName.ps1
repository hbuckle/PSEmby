function Set-OggChapterName {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $InputFile
  )
  $count = 1
  $lines = Get-Content $InputFile
  $output = @()
  foreach ($line in $lines) {
    if ($line.Contains("NAME=")) {
      $line = $line.Split("=")[0] +  "=Chapter ${count}"
      $count++
    }
    $output += $line
  }
  $output | Set-Content $InputFile -Encoding utf8NoBOM -Force
}