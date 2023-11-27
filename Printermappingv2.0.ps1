<#
.SYNOPSIS
    Add print queue and test VPN connectivity

.DESCRIPTION
    This script checks VPN connectivity and adds printers to the user's system. It is useful in environments where VPN connections are essential for accessing networked printers.

.PARAMETERS
    $VPNName: The name of the VPN connection to be tested.
    $PrinterName: The full path and name of the printer to be added.

.EXAMPLE
    Edit the script to include the correct VPN name and printer name at the top, then execute the script.

.NOTES
    Version: 1.0
    Author: R33Dfield
    Created: 30-10-2023

#>

# ------------------------------------------------------------------------------------------------------- #
# User Configuration - Edit these variables as needed
# ------------------------------------------------------------------------------------------------------- #
$VPNName = "YourVPNNameHere" # Replace with your VPN name
$PrinterName = "\\YourPrinterPathHere\YourPrinterName" # Replace with your full printer path and name

#region Functions

Function CleanUpAndExit() {
    Param(
        [Parameter(Mandatory=$True)][String]$ErrorLevel
    )

    # Write results to log file
    $NOW = Get-Date -Format "yyyyMMdd-hhmmss"

    If ($ErrorLevel -eq "0") {
        Write-Host "Printers added successfully at $NOW"
    } else {
        Write-Host "Adding printers failed at $NOW with error $Errorlevel"
    }
    
    # Exit Script with the specified ErrorLevel
    Stop-Transcript | Out-Null
    EXIT $ErrorLevel
}

Function Test-VPNConnection {
    $VPNConnection = Get-VpnConnection -Name $VPNName
    
    if ($VPNConnection -ne $null -and $VPNConnection.ConnectionStatus -eq 'Connected') {
        return $true
    } else {
        return $false
    }
}

Function Test-Printer {
    $Printer = Get-Printer | Where-Object {$_.Name -eq $PrinterName}
    return ($Printer -ne $null)
}

#endregion Functions

# ------------------------------------------------------------------------------------------------------- #
# Start Transcript
# ------------------------------------------------------------------------------------------------------- #
$Transcript = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\$($(Split-Path $PSCommandPath -Leaf).ToLower().Replace(".ps1",".log"))"
Start-Transcript -Path $Transcript | Out-Null

# ------------------------------------------------------------------------------------------------------- #
# Check domain connectivity
# ------------------------------------------------------------------------------------------------------- #

if (Test-VPNConnection -eq $True){
    Write-Host "STATUS: VPN connection OK"
}
else {
    Write-Host "STATUS: No VPN connection. Unable to add printers!"
    CleanUpAndExit -ErrorLevel 1
}

# ------------------------------------------------------------------------------------------------------- #
# Add printers
# ------------------------------------------------------------------------------------------------------- #

if (Test-Printer -eq $True) {
    Write-Host "Printer already present"
} else {
    Add-Printer -ConnectionName $PrinterName
    Write-Host "Printer added"
}

# ------------------------------------------------------------------------------------------------------- #
# Check end state
# ------------------------------------------------------------------------------------------------------- #

if (Test-Printer -eq $True){
    Write-Host "STATUS: Printer present"
}
else {
    Write-Host "STATUS: Printer NOT present, unknown error"
    CleanUpAndExit -ErrorLevel 2
}
