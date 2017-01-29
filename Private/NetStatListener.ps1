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
    $Listener = $InputObject | Where-Object -Property State -EQ -Value 'LISTEN'
    $SelectArguments = @{
        Property = @{
            Name = 'LocalPort';
            Expression = {(($PSItem.LocalAddress).Split(':'))[(($PSItem.LocalAddress).Split(':')).Count-1]}
        },
        @{
            Name = 'OwningProcess';
            Expression = {$PSItem.PID}
        }
    }
    $Listener | Select-Object @SelectArguments
}
