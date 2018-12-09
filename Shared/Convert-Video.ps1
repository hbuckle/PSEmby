function Convert-Video {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$SourceFolder,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String]$X264Tune
  )
  if (-not(Test-Path "$SourceFolder\video.h264")) {
    $job = Start-Job -ScriptBlock {
      Start-Sleep -Seconds 20
      Get-CimInstance win32_process -Filter 'Name="x264.exe"' | Invoke-CimMethod -MethodName SetPriority -Arguments @{Priority = 16384}
      Get-CimInstance win32_process -Filter 'Name="VSPipe.exe"' | Invoke-CimMethod -MethodName SetPriority -Arguments @{Priority = 16384}
    }
    & cmd.exe /c "$($Script:vspipe) --y4m $SourceFolder\video.vpy - | $($Script:x264) --demuxer y4m --crf 18 --tune $X264Tune --preset slow - --output $SourceFolder\video.h264"
    $null = Receive-Job -Job $job
  }
}