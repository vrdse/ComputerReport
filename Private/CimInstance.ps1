function GetCimInstance {
    param (
        [Parameter()]
        [string]
        $ClassName,
        [Parameter()]
        [string[]]
        $Property,
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )
    Get-CimInstance -CimSession $CimSession -ClassName $ClassName -Property $Property
}