function NewCimSession {
    param (
    [Parameter(Mandatory=$true)]
    [string]
    $ComputerName,
    [Parameter()]
    [System.Management.Automation.PSCredential]
    $Credential
    )

    Write-Verbose "Create new CIM session to $ComputerName"
    New-CimSession -ComputerName $ComputerName -Credential $Credential
    Write-Verbose "CIM session to $ComputerName created"
}