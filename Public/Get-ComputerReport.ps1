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


function Get-ComputerReport {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $ComputerName
    )
    
    begin {
    }
    
    process {
        if ($ComputerName) {
            foreach ($Computer in $ComputerName) {
				Write-Verbose "Processing $Computer..."
                if (Test-NetConnection -ComputerName $Computer -InformationLevel Quiet) {
                    Write-Verbose "$Computer is online"
                    if ($Credential) {
                        $CimSession = New-CimSession -ComputerName $Computer -Credential $Credential
                    }
                    else {
                        $CimSession = New-CimSession -ComputerName $Computer
                    }
					
					$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession

					$Hotfix = Get-CimInstance -ClassName Win32_QuickFixEngineering -CimSession $CimSession |
						Select-Object -Property HotFixID,@{Name='Type';Expression={$PSItem.Description}},@{Name='Link';Expression={$PSItem.Caption}},@{Name='InstalledOn';Expression={[DateTime]($PSItem.CimInstanceProperties | Where-Object -Property Name -EQ -Value "InstalledOn").Value}},InstalledBy
						
					$NetworkListener = Get-NetworkListener -CimSession $CimSession
					
					$isOnline = $true
				}
                else {
                    Write-Verbose "$Computer is offline"
                    $isOnline = $false
                }
				[PSCustomObject]@{
                    ComputerName = if ($Computer -eq $null) {$Env:COMPUTERNAME} else {$Computer}
                    OperatingSystem = $OperatingSystem.Caption
                    OSVersion = $OperatingSystem.Version
                    IsOnline = $isOnline
                    InstallDate = $OperatingSystem.InstallDate
                    LastReboot = $OperatingSystem.LastBootUpTime
                    Uptime = (Get-Date) - ($OperatingSystem.LastBootUpTime)
                    LastOSUpdate = ($Hotfix | Sort-Object -Property InstalledOn -Descending | Select-Object -Property InstalledOn -First 1).InstalledOn
                    Hotfix = $Hotfix
                    NetworkListener = $NetworkListener
                    InstalledSoftware = "" 
                    ADObject = ""
                    LocalUser = ""
                    LocalGroup = ""
                    LocalAdmin = ""
                    LocalPriviliges = ""
				}
			}
        }

        

    }
    
    end {
    }
}