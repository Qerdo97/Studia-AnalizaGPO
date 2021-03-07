#Ustawiamy domyślne formaty kodowania do UTF8 aby poprawnie wyświetlać polskie znaki diakrytyczne
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$exercise = "AZ2_Zadanie1"
$name = "Grzegorz"
$lastName = "Sekuła"
$group = "IZ08TC1"
$indexNumber = "17313"
$workDir = "c:\WIT\" + $indexNumber
$user = "$env:USERDOMAIN\$env:USERNAME"

function ManageSecedit
{
    param
    (
        $State
    )

    $Global:secFileName = "secedit.cfg"

    if ($State -eq "run")
    {
        secedit /export /cfg $workDir\$secFileName | Out-Null
    }
    if ($State -eq "stop")
    {
        Remove-Item "$workDir\$secFileName" -Force
    }
}

function CreateFile
{
    $date = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $Global:fileName = "$( $env:COMPUTERNAME )_$( $indexNumber )_$( $date ).csv"
    New-Item -Path $workDir -Name $fileName -Force | Out-Null
    #Header of file
    Add-Content -Path $workDir\$fileName -Value "============INFO============"
    Add-Content -Path $workDir\$fileName -Value "Data wykonania testu: $date"
    Add-Content -Path $workDir\$fileName -Value "Nazwa komputera: $env:COMPUTERNAME"
    Add-Content -Path $workDir\$fileName -Value "Sprawdzenie wykonal: $user"
    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
}

#Funkcja ShowAuthor wyświetla informacje o autorze tego skrypty
function ShowAuthor
{
    Write-Host    $exercise
    Write-Host    ""
    Write-Host    "Author:"
    Write-Host    $name $lastName
    Write-Host    "Grupa:" $group
    Write-Host    "Nr indeksu:" $indexNumber
}

#Funkcja odpowiedzialna za wyświetlanie menu
function ShowMenu
{
    Clear-Host
    Write-Host "========================== MENU =========================="
    Write-Host ""
    Write-Host "                 == Obsługa raportów ==                   "
    Write-Host "1: Wciśnij '1' aby otrzymać raport SECURITY OPTIONS."
    Write-Host "2: Wciśnij '2' aby otrzymać raport USER RIGHTS ASSIGMENT."
    Write-Host "3: Wciśnij '3' aby otrzymać raport WSUS SETTINGS."
    Write-Host "4: Wciśnij '4' aby otrzymać raport USŁUGI SYSTEMOWE."
    Write-Host "5: Wciśnij '5' aby otrzymać raport WSZYSTKIEGO."
    Write-Host "                       == Więcej ==                       "
    Write-Host "A: Wciśnij 'A' aby otrzymać informacje o autorze."
    Write-Host "Q: Wciśnij 'Q' aby wyjść."
    Write-Host ""
    Write-Host "=========================================================="
}

function SecurityOptions
{
    Add-Content -Path $workDir\$fileName -Value "=======SecurityOptions======"
    ManageSecedit -State run
    $adminAccOk = 'NewAdministratorName = "17313_Admin"'
    $guestAccOk = 'NewGuestName = "Guest_17313"'
    $checkAdmin = Get-Content "$workDir\$secFileName" | Select-String -Pattern $adminAccOk
    $checkGuest = Get-Content "$workDir\$secFileName" | Select-String -Pattern $guestAccOk
    if ($adminAccOk = $checkAdmin)
    {
        $message = "Nazwa konta administratora: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Nazwa konta administratora: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }
    if ($guestAccOk = $checkGuest)
    {
        $message = "Nazwa konta gościa: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Nazwa konta gościa: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }
    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
    ManageSecedit -State stop
}

function UserRightsAssigment
{
    Add-Content -Path $workDir\$fileName -Value "=====UserRightsAssigment===="
    ManageSecedit -State run
    $shutdownNames = "g_it", "Domain Admins"
    $shutdownSIDs = @()
    Foreach ($i in $shutdownNames)
    {
        $SID = (New-Object System.Security.Principal.NTAccount($i)).Translate([System.Security.Principal.SecurityIdentifier]).value
        $shutdownSIDs += $SID
    }
    $backupNames = "g_it"
    $backupSIDs = @()
    Foreach ($i in $backupNames)
    {
        $SID = (New-Object System.Security.Principal.NTAccount($i)).Translate([System.Security.Principal.SecurityIdentifier]).value
        $backupSIDs += $SID
    }
    $lookShutdown = "SeShutdownPrivilege"
    $lookBackup = "SeBackupPrivilege"
    $checkShutdown = @(((Get-Content "$workDir\$secFileName" | Select-String -Pattern $lookShutdown).ToString()).TrimStart("SeShutdownPrivilege = ")).Replace("*", "") -split ","
    $checkBackup = @(((Get-Content "$workDir\$secFileName" | Select-String -Pattern $lookBackup).ToString()).TrimStart("SeBackupPrivilege = ")).Replace("*", "") -split ","

    foreach ($i in $checkShutdown)
    {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($i)
        $objUser = ($objSID.Translate([System.Security.Principal.NTAccount])).Value
        if ($shutdownSIDs -contains $i)
        {
            $message = "Objekt $objUser posiada prawa do zamknięcia: Zgodne"
            Add-Content -Path $workDir\$fileName -Value $message
            Write-Host -ForegroundColor Green $message
        }
        else
        {
            $message = "Objekt $objUser posiada prawa do zamknięcia: Niezgodne"
            Add-Content -Path $workDir\$fileName -Value $message
            Write-Host -ForegroundColor Red $message
        }
    }
    foreach ($i in $checkBackup)
    {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($i)
        $objUser = ($objSID.Translate([System.Security.Principal.NTAccount])).Value
        if ($backupSIDs -contains $i)
        {
            $message = "Objekt $objUser posiada prawa do kopii zapasowej: Zgodne"
            Add-Content -Path $workDir\$fileName -Value $message
            Write-Host -ForegroundColor Green $message
        }
        else
        {
            $message = "Objekt $objUser posiada prawa do kopii zapasowej: Niezgodne"
            Add-Content -Path $workDir\$fileName -Value $message
            Write-Host -ForegroundColor Red $message
        }
    }
    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
    ManageSecedit -State stop
}

function WSUSSettings
{
    Add-Content -Path $workDir\$fileName -Value "=========WSUSSettings======="
    $expectedUpdateServiceUrlAlternate = "https://witsus.ocean.local"
    $expectedWUServer = "https://witsus.ocean.local"
    $expectedWUStatusServer = "https://witsus.ocean.local"
    $expectedAUOptions = 4
    $expectedNoAutoUpdate = 0
    $expectedScheduledInstallDay = 0
    $expectedScheduledInstallEveryWeek = 1
    $expectedScheduledInstallTime = 15
    $expectedUseWUServer = 1

    $actualUpdateServiceUrlAlternate = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceUrlAlternate" | Select-Object -ExpandProperty "UpdateServiceUrlAlternate"
    $actualWUServer = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" | Select-Object -ExpandProperty "WUServer"
    $actualWUStatusServer = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUStatusServer" | Select-Object -ExpandProperty "WUStatusServer"
    $actualAUOptions = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "AUOptions" | Select-Object -ExpandProperty "AUOptions"
    $actualNoAutoUpdate = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "NoAutoUpdate" | Select-Object -ExpandProperty "NoAutoUpdate"
    $actualScheduledInstallDay = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "ScheduledInstallDay" | Select-Object -ExpandProperty "ScheduledInstallDay"
    $actualScheduledInstallEveryWeek = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "ScheduledInstallEveryWeek" | Select-Object -ExpandProperty "ScheduledInstallEveryWeek"
    $actualScheduledInstallTime = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "ScheduledInstallTime" | Select-Object -ExpandProperty "ScheduledInstallTime"
    $actualUseWUServer = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" | Select-Object -ExpandProperty "UseWUServer"

    if ($expectedUseWUServer -eq $actualUseWUServer)
    {
        $message = "Włączenie serwera aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Włączenie serwera aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedWUServer -eq $actualWUServer)
    {
        $message = "Główny serwer aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Główny serwer aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedUpdateServiceUrlAlternate -eq $actualUpdateServiceUrlAlternate)
    {
        $message = "Alternatywny serwer aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Alternatywny serwer aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedWUStatusServer -eq $actualWUStatusServer)
    {
        $message = "Serwer statusu aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Serwer statusu aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedAUOptions -eq $actualAUOptions)
    {
        $message = "Automatyczne pobieranie i planowanie aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Automatyczne pobieranie i planowanie aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedNoAutoUpdate -eq $actualNoAutoUpdate)
    {
        $message = "Wyłączenie automatycznych aktualizacji: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Wyłączenie automatycznych aktualizacji: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedScheduledInstallTime -eq $actualScheduledInstallTime)
    {
        $message = "Ustawienie godziny intalacji aktualizacji na godzinę $expectedScheduledInstallTime-00: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Ustawienie godziny intalacji aktualizacji na godzinę $expectedScheduledInstallTime-00: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedScheduledInstallDay -eq $actualScheduledInstallDay)
    {
        $message = "Ustawienie instalacji aktualizacji codziennie: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Ustawienie instalacji aktualizacji codziennie: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    if ($expectedScheduledInstallEveryWeek -eq $actualScheduledInstallEveryWeek)
    {
        $message = "Ustawienie instalacji aktualizacji tygodniowo: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Ustawienie instalacji aktualizacji tygodniowo: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }

    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
}

function SystemServices
{
    Add-Content -Path $workDir\$fileName -Value "========SystemServices======"
    $expectedAppIDSvcStartType = "Automatic"
    $actualAppIDSvcStartType = (Get-Service -Name AppIDSvc | Select-Object *).StartType

    if ($expectedAppIDSvcStartType -eq $actualAppIDSvcStartType)
    {
        $message = "Usługa Application Identity uruchamia się automatycznie: Zgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Green $message
    }
    else
    {
        $message = "Usługa Application Identity uruchamia się automatycznie: Niezgodne"
        Add-Content -Path $workDir\$fileName -Value $message
        Write-Host -ForegroundColor Red $message
    }
    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
}

#Wyświetlenie menu i oczekiwanie na decyzję. Po wybraniu odpowiedniej opcji jest wywoływana odpowiednia funkcja
do
{
    ShowMenu
    $selection = Read-Host "Proszę dokonać wyboru"
    switch ($selection)
    {
        '1' {
            Clear-Host
            CreateFile
            SecurityOptions
        }
        '2' {
            Clear-Host
            CreateFile
            UserRightsAssigment
        }
        '3' {
            Clear-Host
            CreateFile
            WSUSSettings
        }
        '4' {
            Clear-Host
            CreateFile
            SystemServices
        }
        '5' {
            Clear-Host
            CreateFile
            SecurityOptions
            UserRightsAssigment
            WSUSSettings
            SystemServices
        }
        'a' {
            Clear-Host
            ShowAuthor
        }
        'q' {

        }
        Default {
            Clear-Host
            "Nie ma takiej opcji"
        }
    }
    pause
}
until ($selection -eq 'q')
