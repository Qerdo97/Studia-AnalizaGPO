#Ustawiamy domyślne formaty kodowania do UTF8 aby poprawnie wyświetlać polskie znaki diakrytyczne
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$Exercise = "AZ2_Zadanie1"
$Name = "Grzegorz"
$LastName = "Sekuła"
$Group = "IZ08TC1"
$IndexNumber = "17313"
$workDir = "c:\WIT\" + $IndexNumber
$Date = (Get-Date -Format "yyyy-MM-dd_HH:mm:s")
$fileName = "$($env:COMPUTERNAME)_$($IndexNumber)_$($Date).csv"
$domain = Get-ADDomain -Current LocalComputer


function CreateFile
{
    New-Item -Path $workDir -Name $fileName -Force | Out-Null
    #Header of file
    Add-Content -Path "$workDir$fileName" -Value "Data wykonania testu: $Date"
    Add-Content -Path "$workDir$fileName" -Value "Nazwa komputera: $env:COMPUTERNAME"
    Add-Content -Path "$workDir$fileName" -Value "Sprawdzenie wykonal: $env:UserName"
}

#Funkcja ShowAuthor wyświetla informacje o autorze tego skrypty
function ShowAuthor
{
    Write-Host    $Exercise
    Write-Host    ""
    Write-Host    "Author:"
    Write-Host    $Name $LastName
    Write-Host    "Grupa:" $Group
    Write-Host    "Nr indeksu:" $IndexNumber
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
