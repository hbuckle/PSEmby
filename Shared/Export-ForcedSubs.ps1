function Export-ForcedSubs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$InputFile,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$OutputFile
  )
  & bdsup2sub --palette-mode create --forced-only --output $OutputFile $InputFile | Out-Null
}