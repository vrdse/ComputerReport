$ModuleRoot = (Resolve-Path -Path "$PSScriptRoot\..\").Path
#$ModuleName = ($MyInvocation.MyCommand.Name) -replace '\.Tests\.', '.'
#. "$RepositoryPath$ModuleName"

Import-Module "$($ModuleRoot)ComputerReport.psm1"

Describe "Get-Memory" {
    It "returns memory information" {
        Get-Memory | Should Be $true
    }
}