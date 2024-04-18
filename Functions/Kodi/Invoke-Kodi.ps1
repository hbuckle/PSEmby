function Invoke-Kodi {
  [CmdletBinding()]
  param (
    [string]$HostName = 'coreelec.local',
    [int]$Port = 8080,
    [string]$Method,
    [hashtable]$Parameters = @{},
    [string]$UserName = 'kodi',
    [securestring]$Password = ('kodi' | ConvertTo-SecureString -AsPlainText -Force)
  )
  $builder = [System.UriBuilder]::new("http://${Hostname}")
  $builder.Port = $Port
  $builder.Path = 'jsonrpc'
  $credential = [System.Management.Automation.PSCredential]::new(
    $UserName, $Password
  )
  if (!$PSBoundParameters.ContainsKey('Method')) {
    $jsonrpc = Invoke-RestMethod -Authentication Basic -Credential $credential -AllowUnencryptedAuthentication -Method Get -ContentType 'application/json' -Uri $builder.ToString()
    return $jsonrpc
  }
  $body = [ordered]@{
    jsonrpc = '2.0'
    method  = $Method
    params  = $Parameters
    id      = (New-Guid).Guid
  } | ConvertTo-Json -Depth 99 -Compress
  Write-Verbose $body
  $PSDefaultParameterValues = @{
    'Invoke-RestMethod:Authentication'                 = 'Basic'
    'Invoke-RestMethod:AllowUnencryptedAuthentication' = $true
    'Invoke-RestMethod:Body'                           = $body
    'Invoke-RestMethod:ContentType'                    = 'application/json'
    'Invoke-RestMethod:Credential'                     = $credential
    'Invoke-RestMethod:Method'                         = 'Post'
    'Invoke-RestMethod:Uri'                            = $builder.ToString()
  }

  $response = Invoke-RestMethod
  $null -eq $response.error ? ($response.result | Write-Output) : ($response.error | Write-Error)
}
