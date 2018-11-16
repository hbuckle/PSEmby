function Export-ForcedSubs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$InputFile,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
    [string]$OutputFile
  )
  & java -jar $Script:bdsup2sub -D -o $OutputFile $InputFile
}