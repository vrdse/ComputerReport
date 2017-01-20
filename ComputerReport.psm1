# Implement your module commands in this script.

$ModuleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$ModulePublicPath = Join-Path -Path $ModuleRoot -ChildPath 'Public';
Get-ChildItem -Path $ModulePublicPath -Include *.ps1 -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing script file ''{0}''.' -f $PSItem.FullName);
        . $PSItem.FullName;
    }

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*


