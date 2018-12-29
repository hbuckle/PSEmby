function Copy-FileName {
  [CmdletBinding()]
  param (
    [string]$SourceFolder,
    [string]$DestinationFolder,
    [string]$Extension
  )
  $names = (Get-ChildItem "$SourceFolder\*" -Include "*.$Extension").Name
  $items = Get-ChildItem "$DestinationFolder\*" -Include "*.$Extension"
  $count = 0
  foreach ($item in $items) {
    Rename-Item $item.FullName -NewName $names[$count]
    $count++
  }
}