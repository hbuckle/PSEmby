using namespace System.Xml.Linq

Add-Type -TypeDefinition '
using System;
using System.IO;
using System.Text;
namespace PSEmby {
  public class Utf8StringWriter : StringWriter {
    public override Encoding Encoding { get { return Encoding.UTF8; } }
    public override String NewLine { get { return "\n"; } }
  }
}
'

function Set-FilmNfo {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InputFile,

    [Int64]$TmdbId,

    [ValidateSet('Action', 'Adventure', 'Drama', 'Comedy', 'Fantasy', 'Horror', 'Romance', 'Science Fiction', 'Thriller', 'War', 'Western')]
    [string[]]$Genre = @(),

    [string]$Description = [string]::Empty,

    [string]$ParentalRating = [string]::Empty
  )
  process {
    foreach ($item in $InputFile) {
      $file = Get-Item $item
      $extension = $file.Extension
      if ($extension -ne '.mkv') {
        Write-Error "Input file '$($file.FullName)' was not in the correct format"
      }
      $output = [System.IO.Path]::ChangeExtension($file.FullName, '.nfo')
      if ([regex]::IsMatch($file.BaseName, '^[\w\s]+Part [1-9]$')) {
        $trimmedName = $file.BaseName.Substring(0, $file.BaseName.Length - ' Part x'.Length)
        if ([System.IO.Directory]::GetFiles($file.Directory.FullName, "${trimmedName} Part *$($file.Extension)").Count -gt 1) {
          $output = Join-Path $file.Directory.FullName "${trimmedName}.nfo"
        }
      }

      if (Test-Path $output) {
        $currentDocument = [XDocument]::Load($output)
        $currentString = [System.IO.File]::ReadAllText($output)
      }
      else {
        $currentDocument = [XDocument]::new([XDeclaration]::new('1.0', 'utf-8', 'yes'))
        $currentString = ''
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId') -and $null -eq $currentDocument.Root?.Element('uniqueid').Value) {
        Write-Error 'TmdbId is required'
      }
      if (!$PSBoundParameters.ContainsKey('TmdbId')) {
        $TmdbId = $currentDocument.Root?.Element('uniqueid').Value
      }
      if (!$PSBoundParameters.ContainsKey('Description')) {
        $Description = $currentDocument.Root?.Element('plot').Value
      }
      if (!$PSBoundParameters.ContainsKey('ParentalRating')) {
        $ParentalRating = $currentDocument.Root?.Element('mpaa').Value
      }
      Write-Progress -Activity 'Set-FilmNfo' -Status $file.FullName

      $tmdbFilm = Get-TmdbFilm -Id $TmdbId -Verbose:$false
      $credits = Get-TmdbFilmCredits -Id $tmdbFilm.id -Verbose:$false
      $tags = Get-FilmTag -InputFile $file.FullName

      $document = [XDocument]::new(
        [XDeclaration]::new('1.0', 'utf-8', 'yes'),
        [XElement]::new('movie',
          [XElement]::new('title', (Get-TitleCaseString $tmdbFilm.title)),
          [XElement]::new('sorttitle', $file.Directory.Name),
          [XElement]::new('premiered', $tmdbFilm.release_date),
          [XElement]::new('mpaa', $ParentalRating),
          [XElement]::new('uniqueid', [XAttribute]::new('type', 'tmdb'), $TmdbId),
          [XElement]::new('plot', (Get-StandardString -InputString $Description)),
          ($Genre | ForEach-Object {[XElement]::new('genre', $_)}),
          ($credits.crew | Where-Object job -EQ 'Director' | ForEach-Object {[XElement]::new('director', $_.name)}),
          ($credits.crew | Where-Object job -In 'Writer', 'Screenplay' | ForEach-Object {[XElement]::new('credits', $_.name)}),
          ($tags | ForEach-Object {[XElement]::new('tag', $_)})
        )
      )
      $writer = [PSEmby.Utf8StringWriter]::new()
      $settings = [System.Xml.XmlWriterSettings]::new()
      $settings.Encoding = [System.Text.Encoding]::UTF8
      $settings.Indent = $true
      $settings.NewLineChars = "`n"
      $xmlwriter = [System.Xml.XmlWriter]::Create($writer, $settings)
      $document.Save($xmlwriter)
      $xmlwriter.Dispose()
      $outputString = $writer.ToString()
      if ($currentString -cne $outputString) {
        if ($PSCmdlet.ShouldProcess("Performing the operation `"Set Content`" on target `"Path: ${output}`" with content:`n${outputString}", 'Set Content', $output)) {
          $outputString | Set-Content $output -NoNewline -Encoding utf8NoBOM
        }
      }
    }
  }
  end {
    Write-Progress -Activity 'Set-FilmNfo' -Completed
  }
}
