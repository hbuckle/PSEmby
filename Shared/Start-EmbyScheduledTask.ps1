function Start-EmbyScheduledTask {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Server = 'https://emby.crucible.org.uk',
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $Script:emby_api_key,
    [ValidateNotNullOrEmpty()]
    [string]$TaskName,
    [switch]$WaitForCompletion
  )
  $tasks = Invoke-RestMethod "${Server}/emby/ScheduledTasks?api_key=${ApiKey}"
  $task = $tasks | Where-Object Name -EQ $TaskName
  if ($null -ne $task) {
    $id = $task.Id
    while ($task.State -ne 'Idle') {
      Start-Sleep -Seconds 10
      $task = Invoke-RestMethod "${Server}/emby/ScheduledTasks/${id}?api_key=${ApiKey}"
    }
    $null = Invoke-RestMethod "${Server}/emby/ScheduledTasks/Running/${id}?api_key=${ApiKey}" -Method Post
    if ($WaitForCompletion) {
      do {
        Start-Sleep -Seconds 10
        $task = Invoke-RestMethod "${Server}/emby/ScheduledTasks/${id}?api_key=${ApiKey}"
      } while ($task.State -ne 'Idle')
    }
  }
  else {
    throw "Task $TaskName not found"
  }
}
