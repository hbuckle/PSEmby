class embyclient {
  [string] $baseuri
  [string] $api_key
  embyclient([string] $baseuri, [string] $api_key)
  {
    $this.baseuri = $baseuri
    $this.api_key = "api_key=$api_key"
  }
  [object] invokeapi([string] $path, [string] $querystring)
  {
    $builder = [System.UriBuilder]::new($this.baseuri)
    $builder.Path = $path
    if ([String]::IsNullOrEmpty($querystring)) {
      $querystring = $this.api_key
    }
    else {
      $querystring = $querystring + "&$($this.api_key)"
    }
    $builder.Query = $querystring
    $uri = $builder.ToString()
    $result = Invoke-RestMethod -Method Get -Uri $uri | ConvertTo-Json -Depth 99 | ConvertFrom-Json -AsHashtable
    return $result
  }
  [object] invokeapi([String] $path)
  {
    return $this.invokeapi($path, "")
  }
  [object] getitembyid([string] $id)
  {
    return $this.invokeapi("Items/${id}")
  }
}