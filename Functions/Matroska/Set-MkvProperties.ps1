function Set-MkvProperties {
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
        $json = Get-Content $output | ConvertFrom-Json
        $null = & mkvpropedit --set "title=$($json.title)" $file.FullName
      }

      $mediainfo = Get-MediaInfo -InputFile $file.FullName -AsHashtable
      $ffprobe = Get-Ffprobe -InputFile $file.FullName
      $video = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Video' }
      [object[]]$audio = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Audio' }
      [object[]]$text = $mediainfo.media.track | Where-Object { $_.'@type' -eq 'Text' }
      [object[]]$audioStreams = $ffprobe.streams | Where-Object { $_.codec_type -eq 'audio' }

      $videoName = Get-MkvVideoName -Track $video -InputFile $file.FullName
      $null = & mkvpropedit --edit track:v1 --set "name=${videoName}" --set language=und $file.FullName

      for ($i = 0; $i -lt $audio.Count; $i++) {
        $mediaInfoTrack = $audio[$i]
        if ($mediaInfoTrack['Title'] -match 'Commentary') {
          $null = & mkvpropedit --edit "track:=$($mediaInfoTrack.UniqueID)" --set flag-commentary=True --set flag-default=False $file.FullName
          continue
        }
        $audioName = Get-MkvAudioName -MediaInfoTrack $mediaInfoTrack -FfprobeTrack $audioStreams[$i]
        $flag_default = $i -eq 0
        $null = & mkvpropedit --edit "track:=$($mediaInfoTrack.UniqueID)" --set "name=${audioName}" --set "flag-default=$($flag_default.ToString())" $file.FullName
      }

      foreach ($track in $text) {
        if ($track['Forced'] -eq 'Yes') {
          $null = & mkvpropedit --edit "track:=$($track.UniqueID)" --set flag-forced=True --set flag-default=True $file.FullName
        }
      }

      $null = & mkvpropedit $file.FullName --tags all:

      Set-MkvChapterName -InputFile $file.FullName
    }
  }
  end {}
}

function Get-MkvVideoName {
  [CmdletBinding()]
  [OutputType([System.String])]
  param (
    [object]$Track,
    [string]$InputFile
  )
  $name = [System.Text.StringBuilder]::new()
  $hdr_formats = @()
  if ($Track['HDR_Format'] -match 'Dolby Vision') {
    $dovi_info = Get-DoviInfo -InputFile $InputFile
    if ($null -eq $dovi_info.SubProfile) {
      $dovi_format = "Dolby Vision $($dovi_info.Profile).$($dovi_info.CrossCompatibilityID)"
    }
    else {
      $dovi_format = "Dolby Vision $($dovi_info.Profile).$($dovi_info.CrossCompatibilityID) $($dovi_info.SubProfile)"
    }
    $hdr_formats += $dovi_format
  }
  if ($Track['HDR_Format'] -match 'SMPTE ST 2094 App 4') {
    $hdr_formats += 'HDR10+'
  }
  if ($Track['HDR_Format'] -match 'SMPTE ST 2086') {
    $hdr_formats += 'HDR10'
  }
  if ($Track.Width -eq 3840) {
    $null = $name.Append('4K ')
  }
  elseif ($Track.Width -eq 1920) {
    $null = $name.Append('FHD ')
  }
  elseif ($Track.Width -eq 1280) {
    $null = $name.Append('HD ')
  }
  else {
    $null = $name.Append('SD ')
  }
  if ($Track.Format -eq 'MPEG Video') {
    $null = $name.Append('MPEG-2')
  }
  else {
    $null = $name.Append($Track.Format)
  }
  if ($hdr_formats.Count -gt 0) {
    $null = $name.Append(' ')
    $null = $name.Append(($hdr_formats -join ' / '))
  }
  return $name.ToString()
}

function Get-MkvAudioName {
  [CmdletBinding()]
  [OutputType([System.String])]
  param (
    [object]$MediaInfoTrack,
    [object]$FfprobeTrack
  )
  $name = [System.Text.StringBuilder]::new()

  $formats = @{
    'AAC LC SBR'      = 'HE-AAC'
    'AC-3'            = 'Dolby Digital'
    'DTS'             = 'DTS'
    'DTS ES XLL'      = 'DTS-HD Master Audio'
    'DTS ES XXCH XBR' = 'DTS-HD High Resolution Audio'
    'DTS XBR'         = 'DTS-HD High Resolution Audio'
    'DTS XLL'         = 'DTS-HD Master Audio'
    'DTS XLL X'       = 'DTS:X'
    'E-AC-3'          = 'Dolby Digital Plus'
    'E-AC-3 JOC'      = 'Dolby Digital Plus with Dolby Atmos'
    'FLAC'            = 'FLAC'
    'MLP FBA'         = 'Dolby TrueHD'
    'MLP FBA 16-ch'   = 'Dolby TrueHD with Dolby Atmos'
    'PCM'             = 'PCM'
  }
  if ($null -eq $formats[$MediaInfoTrack.Format_String]) {
    Write-Error "Unknown Format_String '$($MediaInfoTrack.Format_String)'"
  }
  $null = $name.Append($formats[$MediaInfoTrack.Format_String])
  $null = $name.Append(' ')

  if ($null -ne $FfprobeTrack['channel_layout']) {
    $string = Get-TitleCaseString $FfprobeTrack['channel_layout'].Replace('(side)', '')
    $null = $name.Append($string)
  }
  else {
    if ($null -ne $MediaInfoTrack['ChannelLayout']) {
      $channel_layout = $MediaInfoTrack.ChannelLayout -split ' '
    }
    else {
      $channel_layout = @()
    }
    if ($channel_layout -contains 'LFE') {
      $null = $name.Append(($MediaInfoTrack.Channels - 1))
      $null = $name.Append('.1')
    }
    else {
      $null = $name.Append($MediaInfoTrack.Channels)
      $null = $name.Append('.0')
    }
  }
  return $name.ToString()
}
