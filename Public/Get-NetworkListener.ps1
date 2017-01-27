function Get-NetworkListener {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,
        [Parameter()]
        [ValidateSet(First1000Ports,First30000Ports,All)]
        [string]
        $TestConnection
    )

    $TCPConnections = Get-NetTCPConnection -State Listen -CimSession $CimSession | Select-Object -Property LocalPort, OwningProcess
    $Filter = "ProcessId="+($($TCPConnections.OwningProcess) -join " or ProcessId=")
	Write-Verbose "ProcessIds are $Filter"
    $TCPProcesses = Get-CimInstance -ClassName Win32_Process -Filter $Filter -Property ProcessId,Name,CommandLine | Select-Object -Property ProcessId,Name,CommandLine

    switch ($TestConnection) {
        First1000Ports {$PortsToCheck = 1000}
        First30000Ports {$PortsToCheck = 30000}
        All {$PortsToCheck = 65535}
        Default {$PortsToCheck = $null}
    }

    foreach ($TCPConnection in $TCPConnections) {
		Write-Verbose "Processing $($TCPConnection.LocalPort)"
        if ($PortsToCheck -ne $null) {
            if ($TCPConnection.LocalPort -lt $PortsToCheck) {
                $isReachable = Test-NetConnection -ComputerName $CimSession.ComputerName -Port $TCPConnection.LocalPort -InformationLevel Quiet
            }
        }
        else {
            $isReachable = $null
        }
        $TCPProcess = $TCPProcesses | Where-Object -Property ProcessId -EQ -Value $TCPConnection.OwningProcess
        [PSCustomObject]@{
            Port = $TCPConnection.LocalPort
            isReachable = $isReachable
            ProcessName = $TCPProcess.Name
            ProcessCmd = $TCPProcess.CommandLine
        }
    }
}