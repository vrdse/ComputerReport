function Get-ComputerReport {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
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
                    $CimSession = NewCimSession -ComputerName $ComputerName
					$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession #ersetzen durch @CimSession (splattered argument)

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