function NewCimSession {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]
        $ComputerName,
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    process {
        Write-Verbose "$Computer is online"
        if ($Credential) {
            $CimSession = New-CimSession -ComputerName $Computer -Credential $Credential
        }
        else {
            $CimSession = New-CimSession -ComputerName $Computer
        }
        $CimSession
    }
}