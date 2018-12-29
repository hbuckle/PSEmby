function Get-Sar {
  [CmdletBinding()]
  param (
    [string]$Framesize,
    [string]$DAR
  )
  [double]$width = $Framesize.ToLower().Split("x")[0]
  [double]$height = $Framesize.ToLower().Split("x")[1]

  if ($dar.Contains(":")) {
    [double]$darwidth = $DAR.Split(":")[0]
    [double]$darheight = $DAR.Split(":")[1]
  }
  if ($dar.Contains("/")) {
    [double]$darwidth = $DAR.Split("/")[0]
    [double]$darheight = $DAR.Split("/")[1]
  }
  $top = $darwidth * $height
  $bottom = $darheight * $width
  $gcd = Get-Gcd $top $bottom
  return "$($top / $gcd)/$($bottom / $gcd)"
}

function Get-Gcd {
  [CmdletBinding()]
  param (
    [int]$a,
    [int]$b
  )
  while ($b -gt 0) {
    $rem = $a % $b
    $a = $b
    $b = $rem
  }
  return $a
}