# Set execution policy to unrestricted
Set-ExecutionPolicy Unrestricted -Force

# Initialize a log array to capture all log messages
$log = @()

# Utility function to write logs
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $log += "$(Get-Date) - $Message"
    Write-Output "$(Get-Date) - $Message"
}

try {
    Write-Log "Starting script execution..."

    # Create the directory C:\tools\jenkins-agent
    $jenkinsAgentDir = "C:\tools\jenkins-agent"
    New-Item -ItemType Directory -Force -Path $jenkinsAgentDir
    Write-Log "Created directory: $jenkinsAgentDir"

    # Update the registry...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v DevicePasswordLessBuildVersion /d 0x0 /f /t REG_DWORD
    Write-Log "Registry updated: DevicePasswordLessBuildVersion set to 0"

  

    # Ensure Jenkins agent or related processes are not running...
    Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
    Write-Log "Stopped java processes."

    # Download agent.jar...
    Invoke-WebRequest -Uri "https://jenkins.t6cloud.com/jnlpJars/agent.jar" -OutFile "$jenkinsAgentDir\agent.jar"
    Write-Log "Downloaded agent.jar."

    # Run Jenkins agent...
    Start-Process -FilePath "java.exe" -ArgumentList "-jar $jenkinsAgentDir\agent.jar -jnlpUrl https://jenkins.t6cloud.com/computer/Cucumber/jenkins-agent.jnlp -secret secret -workDir ""$jenkinsAgentDir""" -WorkingDirectory $jenkinsAgentDir
    Write-Log "Started Jenkins agent."

    # Task Scheduler XML configuration
    $jenkinsAgentXml = @"
<?xml version="1.0"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
        <Date>2023-09-20T15:48:40.0519138</Date>
        <Author>jenkins-user</Author>
        <URI>\Start Jenkins agent</URI>
    </RegistrationInfo>
    <Triggers>
        <LogonTrigger>
            <Enabled>true</Enabled>
            <UserId>jenkins-user</UserId>
        </LogonTrigger>
    </Triggers>
    <Principals>
        <Principal id="Author">
            <UserId>jenkins-user</UserId>
            <LogonType>InteractiveToken</LogonType>
            <RunLevel>HighestAvailable</RunLevel>
        </Principal>
    </Principals>
    <Settings>
        <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
        <AllowHardTerminate>false</AllowHardTerminate>
        <StartWhenAvailable>true</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
        <IdleSettings>
            <StopOnIdleEnd>true</StopOnIdleEnd>
            <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>false</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <WakeToRun>false</WakeToRun>
        <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
        <Priority>7</Priority>
        <RestartOnFailure>
            <Interval>PT1M</Interval>
            <Count>999</Count>
        </RestartOnFailure>
    </Settings>
    <Actions Context="Author">
        <Exec>
            <Command>java.exe</Command>
            <Arguments>-jar agent.jar -jnlpUrl https://jenkins.url/computer/Cucumber/jenkins-agent.jnlp -secret secret -workDir "$jenkinsAgentDir"</Arguments>
            <WorkingDirectory>c:\tools\jenkins-agent\</WorkingDirectory>
        </Exec>
    </Actions>
</Task>
"@
    Write-Log "XML configuration generated."

    # Check if task exists and unregister/delete it
    $taskName = "Start Jenkins agent"
    if (Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName}) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Log "Unregistered existing task: $taskName"
    }

    # Register the Windows Task Scheduler task
    Register-ScheduledTask -Xml $jenkinsAgentXml -TaskName $taskName -User "jenkins-user" -Password "*******"
    Write-Log "Task registered: $taskName"

    # Run the task to start the Jenkins agent
    Start-ScheduledTask -TaskName $taskName
    Write-Log "Started task: $taskName"

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
}

# Export logs to a file
$log | Out-File -Path "C:\tools\jenkins_setup_log.txt"

