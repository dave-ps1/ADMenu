#Requires -Module ActiveDirectory

Clear-Host

$User = Read-Host "Search for a student by partial first name, last name, or lunch number"

Write-Host ""
Write-Host "Searching 'OU=name,DC=name,DC=name' for matching users" -ForegroundColor Cyan

# Find AD User Accounts
#[array]$Users = Get-ADUser -Filter "SamAccountName -like '*$User*'" -Properties DisplayName,SamAccountName,Title,DistinguishedName -SearchBase "OU=name,DC=name,DC=name" -Server "DC server address"

$User = "*$User*"
[array]$Users = Get-ADUser -SearchBase "DC=name,DC=name" -Server "DC server address" -Filter { (GivenName -Like $User) -or (SurName -Like $User) -or (DisplayName -Like $User) -or (EmployeeID -like $User) } -Properties *


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

            # Get All AD Properties
            $ADUser = $($Selected.DistinguishedName)
            $GetADUser = Get-ADUser -Filter { DistinguishedName -eq $ADUser } -Properties * -SearchBase "DC=name,DC=name" -Server "DC server address"

            # Display all AD properties
            #$GetADUser

            # Display a custom list of AD properites
            [PsCustomObject][ordered]@{
                GivenName              = $GetADUser.GivenName
                middleName             = $GetADUser.middleName
                Surname                = $GetADUser.Surname
                DisplayName            = $GetADUser.DisplayName
                EmailAddress           = $GetADUser.EmailAddress
                SamAccountName         = $GetADUser.SamAccountName
                UserPrincipalName      = $GetADUser.UserPrincipalName
                DistinguishedName      = $GetADUser.DistinguishedName
                HomeDrive              = $GetADUser.HomeDrive
                HomeDirectory          = $GetADUser.HomeDirectory
                employeeType           = $GetADUser.employeeType
                EmployeeID             = $GetADUser.EmployeeID
                PrinterCode            = $GetADUser.hisdPrinterCode
                Office                 = $GetADUser.Office
                Description            = $GetADUser.Description
                idautoPersonBirthdate  = $GetADUser.idautoPersonBirthdate
                AccountLockoutTime     = $GetADUser.AccountLockoutTime
                LockedOut              = $GetADUser.LockedOut
                Enabled                = $GetADUser.Enabled
                LastLogonDate          = $GetADUser.LastLogonDate
                BadLogonCount          = $GetADUser.BadLogonCount
                badPwdCount            = $GetADUser.badPwdCount
                LastBadPasswordAttempt = $GetADUser.LastBadPasswordAttempt
                PasswordExpired        = $GetADUser.PasswordExpired
                PasswordNeverExpires   = $GetADUser.PasswordNeverExpires
                CannotChangePassword   = $GetADUser.CannotChangePassword
                PasswordLastSet        = $GetADUser.PasswordLastSet
                whenChanged            = $GetADUser.whenChanged
                whenCreated            = $GetADUser.whenCreated
                MemberOf               = $GetADUser.MemberOf
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