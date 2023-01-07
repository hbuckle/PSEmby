function Get-DoviInfo {
  param (
    [string]$InputFile
  )
  $item = Get-Item $InputFile
  $rpu = New-TemporaryFile -WhatIf:$false -Confirm:$false | Select-Object -ExpandProperty FullName
  if ($item.Extension -eq '.mkv') {
    $ffprobe = Get-Ffprobe -InputFile $InputFile
    $side_data = $ffprobe.streams[0].side_data_list | Where-Object side_data_type -EQ 'DOVI configuration record'
    if ($null -ne $side_data) {
      $property = @{
        Profile              = $side_data.dv_profile
        Level                = $side_data.dv_level
        CrossCompatibilityID = $side_data.dv_bl_signal_compatibility_id
      }
      if ($side_data.dv_profile -eq 7) {
        $ffmpeg_path = Get-Alias ffmpeg | Select-Object -ExpandProperty Definition
        $dovi_tool_path = Get-Alias dovi_tool | Select-Object -ExpandProperty Definition
        $command = "${ffmpeg_path} -v quiet -i `"${InputFile}`" -c:v copy -vbsf hevc_mp4toannexb -frames: 1 -f hevc - | ${dovi_tool_path} extract-rpu - -o ${rpu} > null"
        & cmd /c $command
        $dovi_info = & dovi_tool info -i $rpu -f 0 | Select-Object -Skip 1 | ConvertFrom-Json -Depth 99
        $property.SubProfile = $dovi_info.subprofile
      }
      else {
        $property.SubProfile = $null
      }
      New-Object -TypeName PSObject -Property $property | Write-Output
    }
  }
  Remove-Item $rpu -Force -WhatIf:$false -Confirm:$false
}
