function Get-NetworkListener {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,
        [Parameter()]
        [switch]
        $TestAll
    )

    $TCPConnections = Get-NetTCPConnection -State Listen -CimSession $CimSession | Select-Object -Property LocalPort, OwningProcess
    $Filter = "ProcessId="+($($TCPConnections.OwningProcess) -join " or ProcessId=")
	Write-Verbose "ProcessIds are $Filter"
    $TCPProcesses = Get-CimInstance -ClassName Win32_Process -Filter $Filter -Property ProcessId,Name,CommandLine | Select-Object -Property ProcessId,Name,CommandLine

    foreach ($TCPConnection in $TCPConnections) {
		Write-Verbose "Processing $($TCPConnection.LocalPort)"
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