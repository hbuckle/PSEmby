function Get-DoviInfo {
  param (
    [string]$InputFile
  )
  $item = Get-Item $InputFile
  $rpu = New-TemporaryFile | Select-Object -ExpandProperty FullName
  if ($item.Extension -eq '.mkv') {
    $video_info = Get-VideoInfo -Path $InputFile
    $side_data = $video_info.streams[0].side_data_list | Where-Object side_data_type -EQ 'DOVI configuration record'
    if ($null -ne $side_data) {
      $command = "$(Get-Alias ffmpeg | Select-Object -ExpandProperty Definition) -v quiet -i `"${InputFile}`" -c:v copy -vbsf hevc_mp4toannexb -frames: 1 -f hevc - | $(Get-Alias dovi_tool | Select-Object -ExpandProperty Definition) extract-rpu - -o ${rpu} > null"
      & cmd /c $command
      $dovi_info = & dovi_tool info -i $rpu -f 0 | Select-Object -Skip 1 | ConvertFrom-Json -Depth 99
      Write-Output "Dolby Vision 0$($side_data.dv_profile).0$($side_data.dv_level) $($dovi_info.subprofile)"
    }
  }
  Remove-Item $rpu -Force
}
