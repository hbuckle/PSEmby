function Get-FilmTag {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[string]])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputFile
  )
  $file = Get-Item $InputFile
  if ($file.Extension -ne '.mkv') {
    Write-Error "Input file '$($file.FullName)' was not in the correct format"
  }
  $tags = [System.Collections.Generic.List[string]]::new()
  $extras = Join-Path $file.Directory.FullName 'Extras'
  if (Test-Path $extras) {
    $tags.Add('Extras')
  }
  $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Audio' } | ForEach-Object {
    if ($_['Title'] -match 'Commentary') {
      $tags.Add('Commentary')
      return
    }
  }
  $tags = [System.Linq.Enumerable]::Distinct($tags).ToList()
  $tags.Sort()
  $PSCmdlet.WriteObject($tags)
}
