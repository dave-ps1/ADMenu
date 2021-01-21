# This is the Windows PowerShell profile that goes here:
# C:\Users\Your-User-Name\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# What it does: It lets you load script functions or PowerShell code
# into the PowerShell console each time you open a console window.





Clear-Host

Write-Host
Write-Host "HELP DESK MENU"
Write-Host
Write-Host "1x  AD Menu" -ForegroundColor Yellow
Write-Host "2x  Get-ComputerSystemInfo" -ForegroundColor DarkGreen
Write-Host

# ALIASES FOR COMMONLY USED FUNCTIONS
New-Alias -Name 1x -Value AD -Force
New-Alias -Name 2x -Value Get-ComputerSystemInfo -Force

# Dot Source the script function so it is loaded into the current session.
. "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\ADMenu\ADMenu.ps1"
. "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Functions\Get-ComputerSystemInfo.ps1"
