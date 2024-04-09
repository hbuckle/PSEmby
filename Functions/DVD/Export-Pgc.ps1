function Export-Pgc {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline = $true)]
    [System.IO.FileInfo[]]$InputFile,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [int]$PgcNumber,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputFolder
  )
  begin {}
  process {
    foreach ($item in $InputFile) {
      $pgcdemuxargs = @(
        '-pgc',
        $PgcNumber,
        '-m2v',
        'YES',
        '-aud',
        'YES',
        '-sub',
        'YES',
        '-cellt',
        'NO',
        '-title',
        $item.FullName,
        $OutputFolder
      )
      & 'Z:\Programs\PgcDemux-1.2.0.5\PgcDemux.exe' $pgcdemuxargs | Write-Output 'Wait'
      $chaptereditorargs = @(
        $item.DirectoryName,
        $item.BaseName,
        $PgcNumber,
        '--ogg=chapters'
      )
      Push-Location $OutputFolder
      & 'Z:\Programs\chapterEditorCLI-0.01\chapterEditorCLI.exe' $chaptereditorargs
      Pop-Location
    }
  }
  end {}
}
