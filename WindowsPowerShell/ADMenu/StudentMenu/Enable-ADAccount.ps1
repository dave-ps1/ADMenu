#Requires -Module ActiveDirectory

Clear-Host

$User = Read-Host "Search for a student by partial first name, last name, or lunch number"

Write-Host ""
Write-Host "Searching 'OU=name,DC=name,DC=name' for matching users" -ForegroundColor Cyan

# Find AD User Accounts
#[array]$Users = Get-ADUser -Filter "SamAccountName -like '*$User*'" -Properties DisplayName,SamAccountName,Title,DistinguishedName -SearchBase "OU=name,DC=name,DC=name" -Server "DC server address"

$User = "*$User*"
[array]$Users = Get-ADUser -SearchBase "DC=name,DC=name" -Server "DC server address" -Filter { (GivenName -Like $User) -or (SurName -Like $User) -or (DisplayName -Like $User) -or (EmployeeID -Like $User) } -Properties *


if ($Users)
{
    $Script:i=0

    [array]$UserArray = $Users | Sort-Object SurName | Select-Object -Property @{Name="Number";Expression={$Script:i++;$Script:i}},GivenName,SurName,EmployeeID,DistinguishedName

    Do
    {
        #Clear-Host

        $UserArray | Format-Table -AutoSize

        [int]$Result = Read-Host "Select a user by number or 0 to quit"

        # Validate
        if ($Result -ge 1 -and $Result -le $UserArray.Count)
        {
            # Proceed
            $Selected = $UserArray[($Result-1)]
            Write-Host ""
            Write-Host "Processing $($Selected.DistinguishedName)" -ForegroundColor Green
            Write-Host ""

            # Enable an AD Account
            $ADUser = $($Selected.DistinguishedName)
            Enable-ADAccount -Identity $ADUser -Server "DC server address" -Verbose -Confirm

            Write-Host ""
            Write-Host "Enable AD Account change complete" -ForegroundColor Green

            Get-ADUser -Identity $Selected.DistinguishedName -Properties GivenName,SurName,EmployeeID,Enabled,LockedOut -Server 'DC server address' | Select-Object GivenName,SurName,EmployeeID,Enabled,LockedOut

            $Finished = $True
        }
        elseif ($Result -eq 0)
        {
            Write-Host "Quitting" -ForegroundColor Yellow
            # Bail Out
            Return
        }
        else
        {
            Write-Warning "you entered an invalid number."
            Start-sleep -Seconds 1
        }
    }
    Until ($Result -eq 0 -or $Finished)
}
else
{
    Write-Warning "Failed to find any users that matched the name: $User"
}