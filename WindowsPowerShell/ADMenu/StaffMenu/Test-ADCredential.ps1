#Requires -Module ActiveDirectory

Clear-Host

$User = Read-Host "Search for a staff member by partial first name or last name"

Write-Host ""
Write-Host "Searching 'OU=name,DC=name,DC=name' for matching users" -ForegroundColor Cyan

# Find AD User Accounts
#[array]$Users = Get-ADUser -Filter "SamAccountName -like '*$User*'" -Properties DisplayName,SamAccountName,Title,DistinguishedName -SearchBase "OU=name,DC=name,DC=name" -Server "DC server address"

$User = "*$User*"
[array]$Users = Get-ADUser -SearchBase "DC=name,DC=name" -Server "DC server address" -Filter { (GivenName -Like $User) -or (SurName -Like $User) -or (DisplayName -Like $User) } -Properties *


if ($Users)
{
    $Script:i=0

    [array]$UserArray = $Users | Sort-Object SurName | Select-Object -Property @{Name="Number";Expression={$Script:i++;$Script:i}},GivenName,SurName,Title,DistinguishedName

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

            $Username = $Selected.DistinguishedName
            $Password = Read-Host -Prompt "Please enter the password" -AsSecureString
            $PasswordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
            $DS.ValidateCredentials($Username, $PasswordPlainText)

            Write-Host ""
            Write-Host "Password verification complete" -ForegroundColor Green

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