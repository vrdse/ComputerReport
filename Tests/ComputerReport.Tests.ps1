$ModuleRoot = (Resolve-Path -Path "$PSScriptRoot\..\").Path
#$ModuleName = ($MyInvocation.MyCommand.Name) -replace '\.Tests\.', '.'
#. "$RepositoryPath$ModuleName"

Import-Module "$($ModuleRoot)ComputerReport.psm1"

Describe "Get-ComputerReport" {
    It "returns computer information" {
        Get-ComputerReport | Should Be $true
    }
}

Describe "Get-NetworkListener" {
    It "returns network listener" {
        Get-NetworkListener | Should Be $true
    }
}

Describe "CIM" {
    It "returns Hardware Org" {
        (Get-CimInstance -ClassName Win32_OperatingSystem) | Should Be -not $null
    }
}