# ADMenu
A set of AD tools useful for a Help Desk.  Creates a number driven menu.

_

![Alt text](/../main/ADMenu.PNG?raw=true "Optional Title")

_

![Alt text](/../main/ResetPassword.png?raw=true "Optional Title")

_

Place the WindowsPowerShell folder in your Documents folder.

If you have not already done so, open PowerShell with administrator rights and run this command.

set-executionpolicy unrestricted -Force

You only need to do this once to allow PowerShell to execute scripts.

In the ADMenu folder edit each script in each subfolder because you need to change some things.  The server address and search scope for each script so it points to your domain controller in your environment.

example: [array]$Users = Get-ADUser -SearchBase "DC=domain,DC=org" -Server "dc01.domain.org" -Filter { (GivenName -Like $User) -or (SurName -Like $User) -or (DisplayName -Like $User) } -Properties *

That should be it, now open the PowerShell console and type AD to load the menu.

_

*** I also included a useful advanced function in the Fuctions folder.  I use this daily. ***
