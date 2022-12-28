function Add-FilmJsonCollection {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile
  )
  begin {}
  process {
    foreach ($item in $InputFile) {
      $file = Get-Item $item
      if ($file.Extension -ne '.mkv') {
        Write-Error "Input file '$($file.FullName)' was not in the correct format"
      }
      $output = [System.IO.Path]::ChangeExtension($file.FullName, '.json')

      if (Test-Path $output) {
        $jsonMovie = Read-FilmJson -Path $output
      }
      else {
        Write-Error "File '${output}' does not exist"
      }

      $mediainfo = Get-MediaInfo -InputFile $item -AsHashtable
      $video = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Video' }

      if ($video.Sampled_Width -eq 3840 -and $video.Sampled_Height -eq 2160) {
        $null = $jsonMovie.collections.Add('4K Ultra HD')
      }
      else {
        $null = $jsonMovie.collections.Remove('4K Ultra HD')
      }
      if ($video['HDR_Format'] -match 'Dolby Vision') {
        $null = $jsonMovie.collections.Add('Dolby Vision')
      }
      else {
        $null = $jsonMovie.collections.Remove('Dolby Vision')
      }
      if ($video['HDR_Format'] -match 'SMPTE ST 2094 App 4') {
        $null = $jsonMovie.collections.Add('HDR10+')
      }
      else {
        $null = $jsonMovie.collections.Remove('HDR10+')
      }
      $jsonMovie.collections = $jsonMovie.collections | Select-Object -Unique
      $jsonMovie.collections.Sort()
      ConvertTo-JsonSerialize -InputObject $jsonMovie | Set-Content $output -NoNewline
    }
  }
  end {}
}
