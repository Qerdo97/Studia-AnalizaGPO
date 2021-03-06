#Ustawiamy domyślne formaty kodowania do UTF8 aby poprawnie wyświetlać polskie znaki diakrytyczne
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$exercise = "AZ2_Zadanie1"
$name = "Grzegorz"
$lastName = "Sekuła"
$group = "IZ08TC1"
$indexNumber = "17313"
$workDir = "c:\WIT\" + $indexNumber + "\"
$date = (Get-Date -Format "yyyy-MM-dd_HH-mm-s")
$fileName = "$($env:COMPUTERNAME)_$($indexNumber)_$($date).csv"
$user = "$env:USERDOMAIN\$env:USERNAME"

function CreateFile
{
    New-Item -Path $workDir -Name $fileName -Force | Out-Null
    #Header of file
    Add-Content -Path $workDir$fileName -Value "Data wykonania testu: $date"
    Add-Content -Path $workDir$fileName -Value "Nazwa komputera: $env:COMPUTERNAME"
    Add-Content -Path $workDir$fileName -Value "Sprawdzenie wykonal: $user"
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
    $adminAcc = "17313_Admin"
    $guestAcc = "Guest_17313"

}

function UserRightsAssigment
{
    CreateFile
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
