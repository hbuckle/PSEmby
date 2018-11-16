$paths = Get-Content "$PSScriptRoot\paths.json" -Raw | ConvertFrom-Json
foreach ($alias in $paths.alias) {
  Set-Alias -Name $alias.name -Value $alias.value
}
foreach ($script in $paths.script) {
  New-Variable -Name $script.name -Value $script.value -Scope "Script"
}