function Invoke-Process {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FilePath,

    [string[]]$ArgumentList = @(),

    [string]$WorkingDirectory = $PWD.Path
  )
  $result = [PSEmby.Process]::Invoke(
    $FilePath, $ArgumentList, $WorkingDirectory
  )
  Write-Output $result
}
