@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'ComputerReport.psm1'

# Version number of this module.
ModuleVersion = '0.0.1'

# ID used to uniquely identify this module
GUID = 'be565b39-9deb-421f-b44f-990f5b345859'

# Author of this module
Author = 'VRDSE'

# Company or vendor of this module
CompanyName = 'VRDSE'

# Copyright statement for this module
Copyright = 'Copyright (c) 2017 by VRDSE, licensed under MIT License.'

# Description of the functionality provided by this module
Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module
#FunctionsToExport = @(
#    'Get-ComputerReport'
#)

# # Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = @(
)

# # Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

PrivateData = @{
    # PSData is module packaging and gallery metadata embedded in PrivateData
    # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
    # We had to do this because it's the only place we're allowed to extend the manifest
    # https://connect.microsoft.com/PowerShell/feedback/details/421837
    PSData = @{
            Tags = @('PowerShell','ComputerInfo','Report','Network');
            LicenseUri = 'https://github.com/vrdse/ComputerReport/blob/master/LICENSE';
            ProjectUri = 'https://github.com/vrdse/ComputerReport';
            IconUri = '';
    }
}

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
