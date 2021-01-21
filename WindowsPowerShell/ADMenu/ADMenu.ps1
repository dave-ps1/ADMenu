function AD {

    Clear-Host

    # Get the local path, where the main script is located.
    $Path = Split-Path -Parent $PSCommandPath

    # Path to the Staff Menu folder.
    [array]$StaffMenu = Get-ChildItem -Path "$Path\StaffMenu" | Where-Object { ($_.Name -like "*.ps1") }

    # Path to the Student Menu folder.
    [array]$StudentMenu = Get-ChildItem -Path "$Path\StudentMenu" | Where-Object { ($_.Name -like "*.ps1") }

    Function StaffMenu {
        Clear-Host
        Write-Host "               HELP DESK AD MENU               "
        Write-Host
        Write-Host "                  STAFF MENU" -ForegroundColor Green
        Write-Host
        # Check if the Staff Menu folder contains any .ps1 scripts.
        If ($StaffMenu) {
            # Build the menu choices based on all .ps1 files found in the Staff Menu folder.
            # The For statement (also known as a For loop) is a language construct.
            for ($i=0; $i -le $StaffMenu.GetUpperBound(0); $i++) {
                Write-Host `t$($i+1)"."($StaffMenu[$i].basename)
                Write-Host
            }
            # Add the Student Menu option as the last choice on the menu.
            Write-Host `t$(($StaffMenu | measure).count +1)". STUDENT MENU"`n -ForegroundColor Yellow
            # Prompt for a menu choice.
            Write-Host " Enter a menu number to execute action: " -NoNewline
            $choice = Read-Host
            while (1..(($StaffMenu | measure).count +1) -Notcontains $choice) {
                $choice = Read-Host " Please enter a menu number. Or Press Control C to exit menu"
            }
            if (1..(($StaffMenu | measure).count) -contains $choice) {
                # Run the chosen script.
                & ("$Path\StaffMenu\"+$StaffMenu[[int]$choice-1].name)
            }
            elseif ($choice -eq ($StaffMenu | measure).count +1) {
                StudentMenu
            }
        }
    }

    Function StudentMenu {
        Clear-Host
        Write-Host "               HELP DESK AD MENU               "
        Write-Host
        Write-Host "                  STUDENT MENU" -ForegroundColor Yellow
        Write-Host
        # Check if the Student Menu folder contains any .ps1 scripts.
        If ($StudentMenu) {
            # Build the menu choices based on all .ps1 files found in the Student Menu folder.
            # The For statement (also known as a For loop) is a language construct.
            for ($i=0; $i -le $StudentMenu.GetUpperBound(0); $i++) {
                Write-Host `t$($i+1)"."($StudentMenu[$i].basename)
                Write-Host
            }
            # Add the Staff Menu option as the last choice on the menu.
            Write-Host `t$(($StudentMenu | measure).count +1)". STAFF MENU"`n -ForegroundColor Green
            # Prompt for a menu choice.
            Write-Host " Enter a menu number to execute action: " -NoNewline
            $choice = Read-Host
            while (1..(($StudentMenu | measure).count +1) -Notcontains $choice) {
                $choice = Read-Host " Please enter a menu number. Or Press Control C to exit menu"
            }
            if (1..(($StudentMenu | measure).count) -contains $choice) {
                # Run the chosen script.
                & ("$Path\StudentMenu\"+$StudentMenu[[int]$choice-1].name)
            }
            elseif ($choice -eq ($StudentMenu | measure).count +1) {
                StaffMenu
            }
        }
        else {
            Write-Host `n`t"No scripts in the Student Menu folder."
            # Prompt to return to the menu.
            Write-Host `n"Press Enter to return to the Staff Menu or any other key to cancel" -ForegroundColor Cyan
            If (($Host.UI.RawUI.ReadKey()).VirtualKeyCode -eq 13) {
                StaffMenu
            }
        }
    }

    # Call the Staff Menu function.
    StaffMenu

} # end AD function