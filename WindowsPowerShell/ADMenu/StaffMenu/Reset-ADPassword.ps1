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

            # Verify if password matches, if it does set password.
            #$Password1 = Read-Host "Enter the password for $($Selected.DistinguishedName)" -AsSecureString
            #$Password2 = Read-Host "Re-enter the password for $($Selected.DistinguishedName)" -AsSecureString
            #$Password1_PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password1))
            #$Password2_PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2))

            #if ($Password1_PlainText -ceq $Password2_PlainText) {


# If no password is given it will prompt for password automatically
$password1 = ConvertTo-SecureString -AsPlainText 'password' -Force

                Write-Host
                Set-ADAccountPassword -Identity $($Selected.DistinguishedName) -NewPassword $Password1 -Reset -Server "DC server address" -Verbose

            #}
            #else {
                #Write-Host "The passwords entered do not match, try again."
                #break
            #}

            Write-Host
            Write-Host "Require a Password Change at Next Logon? Type Yes or No: " -ForegroundColor Yellow -NoNewline
            $Prompt = Read-Host

            if ($Prompt -like 'y*') {

                Write-Host
                Set-ADUser -Identity $($Selected.DistinguishedName) -ChangePasswordAtLogon $True -Server "DC server address" -Verbose

            }
            else {
                Write-Host
                Write-Host "You specified no, skipping password change at next logon." -ForegroundColor Yellow
            }

            Write-Host ""
            Write-Host "Password change complete" -ForegroundColor Green

            $Userend = Get-ADUser -Identity $($selected.DistinguishedName) -Properties GivenName,SurName,PasswordLastSet -server 'DC server address' | Select-Object GivenName,SurName,PasswordLastSet

[PsCustomObject][ordered]@{
GivenName = $userend.givenname
SurName = $userend.surname
PasswordLastSet = $userend.passwordlastset
NewPassword = $password1
}

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