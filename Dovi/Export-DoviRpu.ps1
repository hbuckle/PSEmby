function Export-DoviRpu {
  [CmdletBinding()]
  param (
    [string]$InputFile,
    [string]$OutputFile
  )
  if ([string]::IsNullOrEmpty($OutputFile)) {
    $outputFolder = Split-Path $InputFile -Parent
    $OutputFile = Join-Path $outputFolder 'rpu.bin'
  }
  & dovi_tool extract-rpu -i $InputFile -o $OutputFile
}
