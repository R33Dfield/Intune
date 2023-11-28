<#
  .SYNOPSIS
  Detection script for local user account that is controlled by Windows LAPS

  .DESCRIPTION
  Detects if local user account is already present for use with Windows LAPS and gives output.
#>
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\LAPSLocalAdmin_Detect.log" -Append
$LAPSAdmin = "your_local_admin_account_name"
$Query = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
If ($Query.Name -notcontains $LAPSAdmin) {
    Write-Output "User: $LAPSAdmin does not existing on the device"
        
    Exit 1
}
Else {
    Write-Output "User $LAPSAdmin exists on the device"
    Exit 0
}
Stop-Transcript
