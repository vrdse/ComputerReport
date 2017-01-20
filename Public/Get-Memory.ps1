Function Get-Memory {
    Get-CimInstance -ClassName Win32_PhysicalMemory
}