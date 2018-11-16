function Get-TitleCaseString {
  [CmdletBinding()]
  param (
    [string]$InputString
  )
  [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($InputString)
}