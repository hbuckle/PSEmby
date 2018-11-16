class tmdbclient {
  [String] $baseuri = "https://api.themoviedb.org/3"
  [String] $api_key
  tmdbclient([String] $api_key)
  {
    $this.api_key = "api_key=$api_key"
  }
  [Object] invokeapi([String] $path, [String] $querystring)
  {
    if ([String]::IsNullOrEmpty($querystring)) {
      $querystring = $this.api_key
    }
    else {
      $querystring = $querystring + "&$($this.api_key)"
    }
    $uri = "$($this.baseuri)${path}?${querystring}"
    $result = Invoke-RestMethod -Method Get -Uri $uri
    return $result
  }
  [Object] invokeapi([String] $path)
  {
    return $this.invokeapi($path, "")
  }
  [Object] getfilm([String] $id)
  {
    $path = "/movie/${id}"
    return $this.invokeapi($path)
  }
  [Object] getfilmcredits([String] $id)
  {
    $path = "/movie/${id}/credits"
    return $this.invokeapi($path)
  }
  [Object] gettvseason([String] $id, [String] $seasonnumber)
  {
    $path = "/tv/${id}/season/${seasonnumber}"
    return $this.invokeapi($path)
  }
  [Object] gettvepisodegroups([String] $id)
  {
    $path = "/tv/${id}/episode_groups"
    return $this.invokeapi($path)
  }
  [Object] getperson([String] $id)
  {
    $path = "/person/${id}"
    return $this.invokeapi($path)
  }
  [Object] searchfilm([String] $query)
  {
    return $this.search("movie", $query)
  }
  [Object] searchtvshow([String] $query)
  {
    return $this.search("tv", $query)
  }
  [Object[]] search([String] $target, [String] $query)
  {
    $path = "/search/${target}"
    $querystring = "query=${query}"
    $response = $this.invokeapi($path, $querystring)
    $firstpage = $response
    $pages = [Object[]]::new($firstpage.total_pages)
    $pages[0] = $firstpage
    for ($i = 1; $i -lt [Int]$firstpage.total_pages; $i++) {
      $pagenumber = $i + 1
      $nextquerystring = "${querystring}&page=${pagenumber}"
      $pages[$i] = $this.invokeapi($path, $nextquerystring)
    }
    $result = @()
    foreach ($page in $pages) {
      $result += $page.results
    }
    return $result
  }
}