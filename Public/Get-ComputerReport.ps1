function Get-NetworkListener {
    [CmdletBinding()]
    param (
        [Parameter()]
        [CimSession]
        $CimSession,
        [Parameter()]
        [switch]
        $TestAll
    )

    $TCPConnections = Get-NetTCPConnection -State Listen -CimSession $CimSession | Select-Object -Property LocalPort, OwningProcess
    $Filter = "ProcessId="+($($TCPConnections.OwningProcess) -join " or ProcessId=")
    $TCPProcesses = Get-CimInstance -ClassName Win32_Process -Filter $Filter -Property ProcessId,Name,CommandLine | Select-Object -Property ProcessId,Name,CommandLine

    foreach ($TCPConnection in $TCPConnections) {
        if ($TestAll -ne $true) {
            if ($TCPConnection.LocalPort -lt 30000) {
                $isReachable = Test-NetConnection -ComputerName $CimSession.ComputerName -Port $TCPConnection.LocalPort -InformationLevel Quiet
            }
            else {
                $isReachable = $null
            }
        }
        else {
            $isReachable = Test-NetConnection -ComputerName $CimSession.ComputerName -Port $TCPConnection.LocalPort -InformationLevel Quiet
        }
        $TCPProcess = $TCPProcesses | Where-Object {$PSItem.ProcessId -eq $TCPConnection.OwningProcess}
        [PSCustomObject]@{
            Port = $TCPConnection.LocalPort
            isReachable = $isReachable
            ProcessName = $TCPProcess.Name
            ProcessCmd = $TCPProcess.CommandLine
        }
    }
}


function Get-ComputerReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $ComputerName
    )
    
    begin {
    }
    
    process {
        $isOnline = $true
        if ($ComputerName) {
            foreach ($Computer in $ComputerName) {
                if (Test-NetConnection -ComputerName $Computer -InformationLevel Quiet) {
                    Write-Verbose "$Computer is online"
                    if ($Credential) {
                        $CimSession = New-CimSession -ComputerName $Computer -Credential $Credential
                    }
                    else {
                        $CimSession = New-CimSession -ComputerName $Computer
                    }
                $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession

                $Hotfix = Get-CimInstance -ClassName Win32_QuickFixEngineering -Property HotFixID,Description,Caption,InstalledOn,InstalledBy -CimSession $CimSession

                $NetworkListener = Get-NetworkListener -CimSession $CimSession
                

                [PSCustomObject]@{
                    ComputerName = if ($Computer -eq $null) {$Env:COMPUTERNAME} else {$Computer}
                    OperatingSystem = $OperatingSystem.Caption
                    OSVersion = $OperatingSystem.Version
                    IsOnline = $isOnline
                    InstallDate = $OperatingSystem.InstallDate
                    LastReboot = $OperatingSystem.LastBootUpTime
                    Uptime = (Get-Date) - ($OperatingSystem.LastBootUpTime)
                    LastOSUpdate = ($Hotfix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1).InstalledOn
                    Hotfix = ($Hotfix | Select-Object -Property HotFixID,@{Name='Type';Expression={$PSItem.Description}},@{Name='Link';Expression={$PSItem.Caption}},InstalledOn,InstalledBy) 
                    NetworkListener = $NetworkListener
                    InstalledSoftware = "" 
                    ADObject = ""
                    LocalUser = ""
                    LocalGroup = ""
                    LocalAdmin = ""
                    LocalPriviliges = ""
                }
                }
                else {
                    Write-Verbose "$Computer is offline"
                    $isOnline = $false
                }
            }
        }

        

    }
    
    end {
    }
}