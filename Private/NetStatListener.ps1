function Convertfrom-Netstat {
    param (
        # Expects input from netstat -aon in english language
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string[]]
        $Input
    )

    $Input = $Input[4..$Input.Count]
    $InputObject = $Input | ConvertFrom-String -PropertyNames Empty, Protocol, LocalAddress, RemoteAddress, State, PID
    #$Listener = $InputObject | Where-Object -Property State -EQ -Value 'LISTENING'
    $SelectArguments = @{
        Property = @{
            Name = 'LocalAddress';
            Expression = {((($PSItem.LocalAddress).Split(':'))[0..(($PSItem.LocalAddress).Split(':')).Count-1]) -join ':'}
        },
        @{
            Name = 'LocalPort';
            Expression = {(($PSItem.LocalAddress).Split(':'))[(($PSItem.LocalAddress).Split(':')).Count-1]}
        },
        @{
            Name = 'RemoteAddress';
            Expression = {((($PSItem.RemoteAddress).Split(':'))[0..(($PSItem.RemoteAddress).Split(':')).Count-1]) -join ':'}
        },
        @{
            Name = 'RemotePort';
            Expression = {(($PSItem.RemoteAddress).Split(':'))[(($PSItem.RemoteAddress).Split(':')).Count-1]}
        },       
        'State',
        @{
            Name = 'OwningProcess';
            Expression = {$PSItem.PID}
        }
    }
    $InputObject | Select-Object @SelectArguments
}
