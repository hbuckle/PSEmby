function Get-BBFCRating {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$Title
  )
  $query = '
  query Search($title: String!, $page:Int!) {
    search(url: "https://www.bbfc.co.uk/", searchTerm: $title, page: $page, excludeArticles: true) {
      results {
        title
        classification
        type
        date
        dataType
        id
      }
    }
  }
  '.TrimStart().TrimEnd()
  $results = @()
  $page = 1
  $more = $true
  do {
    $body = @{
      query     = $query
      variables = @{
        title = $Title
        page  = $page
      }
    } | ConvertTo-Json -Depth 99 -Compress
    $response = Invoke-RestMethod -Uri "https://www.bbfc.co.uk/graphql" -Body $body -ContentType "application/json" -Method Post
    $results += $response.data.search.results
    if ($response.data.search.results.Count -eq 0) {
      $more = $false
    }
    else {
      $null = $page++
    }
  } while ($more)

  $choice = Select-ItemFromList -List $results -Properties @("title", "date", "type", "classification") -Title "Rating"
  $rating = ""
  if ($null -ne $choice) {
    $rating = "GB-$($choice.classification)"
  }
  Write-Output $rating
}
