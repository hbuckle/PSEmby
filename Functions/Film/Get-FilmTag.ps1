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
  $mediainfo = Get-MediaInfo -InputFile $file.FullName -AsHashtable
  $video = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Video' }
  if ($video['HDR_Format'] -match 'Dolby Vision') {
    $dovi_info = Get-DoviInfo -InputFile $file.FullName
    if ($null -eq $dovi_info.ELType) {
      $dovi_format = "Dolby Vision $($dovi_info.Profile).$($dovi_info.CrossCompatibilityID)"
    }
    else {
      $dovi_format = "Dolby Vision $($dovi_info.Profile).$($dovi_info.CrossCompatibilityID) $($dovi_info.ELType)"
    }
    $tags.Add($dovi_format)
  }
  if ($video['HDR_Format'] -match 'SMPTE ST 2094 App 4') {
    $tags.Add('HDR10+')
  }
  if ($video['HDR_Format'] -match 'SMPTE ST 2086') {
    $tags.Add('HDR10')
  }
  if ($video.Width -eq 3840) {
    $tags.Add('4K')
  }
  elseif ($video.Width -eq 1920) {
    $tags.Add('FHD')
  }
  elseif ($video.Width -eq 1280) {
    $tags.Add('HD')
  }
  else {
    $tags.Add('SD')
  }
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
  return $tags
}
