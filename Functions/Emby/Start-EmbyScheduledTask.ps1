function Start-EmbyScheduledTask {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [switch]$Wait
  )
  $tasks = Invoke-Emby -Path 'ScheduledTasks'
  $task = $tasks | Where-Object Name -EQ $Name
  if ($null -ne $task) {
    $id = $task.Id
    while ($task.State -ne 'Idle') {
      Start-Sleep -Seconds 5
      $task = Invoke-Emby -Path "ScheduledTasks/${id}"
    }
    $null = Invoke-Emby -Path "ScheduledTasks/Running/${id}" -Method Post
    if ($Wait.ToBool()) {
      do {
        Start-Sleep -Seconds 5
        $task = Invoke-Emby -Path "ScheduledTasks/${id}"
      } while ($task.State -ne 'Idle')
    }
  }
  else {
    Write-Error "Task ${Name} not found"
  }
}
