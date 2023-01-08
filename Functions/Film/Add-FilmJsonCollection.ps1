function Add-FilmJsonCollection {
  [CmdletBinding(SupportsShouldProcess = $true)]
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
      Write-Progress -Activity 'Add-FilmJsonCollection' -Status $file.FullName

      $mediainfo = Get-MediaInfo -InputFile $item -AsHashtable
      $video = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Video' }

      $collections = [System.Collections.Generic.List[string]]::new($jsonMovie.collections)
      if ($video.Sampled_Width -eq 3840 -and $video.Sampled_Height -eq 2160) {
        $null = $collections.Add('4K Ultra HD')
      }
      else {
        $null = $collections.Remove('4K Ultra HD')
      }
      if ($video['HDR_Format'] -match 'Dolby Vision') {
        $null = $collections.Add('Dolby Vision')
      }
      else {
        $null = $collections.Remove('Dolby Vision')
      }
      if ($video['HDR_Format'] -match 'SMPTE ST 2094 App 4') {
        $null = $collections.Add('HDR10+')
      }
      else {
        $null = $collections.Remove('HDR10+')
      }
      $commentary = $mediainfo.media.track | Where-Object {
        $_.'@type' -eq 'Audio' -and $_['Title'] -match 'Commentary'
      }
      if ($null -ne $commentary) {
        $null = $collections.Add('Commentaries')
      }
      else {
        $null = $collections.Remove('Commentaries')
      }
      $collections = [System.Linq.Enumerable]::Distinct($collections).ToList()
      $collections.Sort()
      if (![System.Linq.Enumerable]::SequenceEqual($jsonMovie.collections, $collections)) {
        $content = @{collections = $collections} | ConvertTo-Json
        if ($PSCmdlet.ShouldProcess("Performing the operation `"Set Content`" on target `"Path: ${output}`" with content:`n${content}", 'Set Content', $output)) {
          $jsonMovie.collections = $collections
          ConvertTo-JsonSerialize -InputObject $jsonMovie | Set-Content $output -NoNewline
        }
      }
    }
  }
  end {
    Write-Progress -Activity 'Add-FilmJsonCollection' -Completed
  }
}
