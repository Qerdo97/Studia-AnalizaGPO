#Ustawiamy domyślne formaty kodowania do UTF8 aby poprawnie wyświetlać polskie znaki diakrytyczne
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$exercise = "AZ2_Zadanie1"
$name = "Grzegorz"
$lastName = "Sekuła"
$group = "IZ08TC1"
$indexNumber = "17313"
$workDir = "c:\WIT\" + $indexNumber
$date = (Get-Date -Format "yyyy-MM-dd_HH-mm-s")
$fileName = "$($env:COMPUTERNAME)_$($indexNumber)_$($date).csv"
$user = "$env:USERDOMAIN\$env:USERNAME"

function CreateFile
{
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
    CreateFile
    Add-Content -Path $workDir\$fileName -Value "=======SecurityOptions======"
    $secFileName = "secedit.cfg"
    secedit /export /cfg $workDir\$secFileName | Out-Null
    $adminAccOk = 'NewAdministratorName = "17313_Admin"'
    $guestAccOk = 'NewGuestName = "Guest_17313"'
    $checkAdmin = Get-Content "$workDir\$secFileName" | Select-String -Pattern $adminAccOk
    $checkGuest = Get-Content "$workDir\$secFileName" | Select-String -Pattern $guestAccOk
    if ($adminAccOk = $checkAdmin)
    {
        Add-Content -Path $workDir\$fileName -Value "Nazwa konta administratora: Zgodne"
        Write-Host -ForegroundColor Green "Nazwa konta administratora: Zgodne"
    }
    else
    {
        Add-Content -Path $workDir\$fileName -Value "Nazwa konta administratora: Niezgodne"
        Write-Host -ForegroundColor Red "Nazwa konta administratora: Niezgodne"
    }
    if ($guestAccOk = $checkGuest)
    {
        Add-Content -Path $workDir\$fileName -Value "Nazwa konta gościa: Zgodne"
        Write-Host -ForegroundColor Green "Nazwa konta gościa: Zgodne"
    }
    else
    {
        Add-Content -Path $workDir\$fileName -Value "Nazwa konta gościa: Niezgodne"
        Write-Host -ForegroundColor Red "Nazwa konta gościa: Niezgodne"
    }
    Add-Content -Path $workDir\$fileName -Value "============================"
    Add-Content -Path $workDir\$fileName -Value ""
    Remove-Item "$workDir\$secFileName" -Force
}

function UserRightsAssigment
{
    CreateFile
    Add-Content -Path $workDir\$fileName -Value "=====UserRightsAssigment===="
    secedit /export /cfg $workDir\secedit.cfg | Out-Null
    $shutdownNames = "g_it","Domain Admins"
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
    $checkShutdown = @(((Get-Content "$workDir\$secFileName" | Select-String -Pattern $lookShutdown).ToString()).TrimStart("SeShutdownPrivilege = ")).Replace("*","") -split ","
    $checkBackup = @(((Get-Content "$workDir\$secFileName" | Select-String -Pattern $lookBackup).ToString()).TrimStart("SeBackupPrivilege = ")).Replace("*","") -split ","

    foreach ($i in $checkShutdown)
    {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($i)
        $objUser = ($objSID.Translate([System.Security.Principal.NTAccount])).Value
        if ($shutdownSIDs -contains $i)
        {
            Add-Content -Path $workDir\$fileName -Value "Objekt $objUser posiada prawa do zamknięcia: Zgodne"
            Write-Host -ForegroundColor Green "Objekt $objUser posiada prawa do zamknięcia: Zgodne"
        }
        else
        {
            Add-Content -Path $workDir\$fileName -Value "Objekt $objUser posiada prawa do zamknięcia: Niezgodne"
            Write-Host -ForegroundColor Red "Objekt $objUser posiada prawa do zamknięcia: Niezgodne"
        }
    }
    foreach ($i in $checkBackup)
    {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($i)
        $objUser = ($objSID.Translate([System.Security.Principal.NTAccount])).Value
        if ($backupSIDs -contains $i)
        {
            Add-Content -Path $workDir\$fileName -Value "Objekt $objUser posiada prawa do kopii zapasowej: Zgodne"
            Write-Host -ForegroundColor Green "Objekt $objUser posiada prawa do kopii zapasowej: Zgodne"
        }
        else
        {
            Add-Content -Path $workDir\$fileName -Value "Objekt $objUser posiada prawa do kopii zapasowej: Niezgodne"
            Write-Host -ForegroundColor Red "Objekt $objUser posiada prawa do kopii zapasowej: Niezgodne"
        }
    }
    Remove-Item "$workDir\$secFileName" -Force
}

function WSUSSettings
{
    CreateFile
}

function SystemServices
{
    CreateFile
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
            SecurityOptions
        }
        '2' {
            Clear-Host
            UserRightsAssigment
        }
        '3' {
            Clear-Host
            WSUSSettings
        }
        '4' {
            Clear-Host
            SystemServices
        }
        '5' {
            Clear-Host
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
