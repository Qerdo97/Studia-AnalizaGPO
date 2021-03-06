#Ustawiamy domyślne formaty kodowania do UTF8 aby poprawnie wyświetlać polskie znaki diakrytyczne
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

#Funkcja Author zawiera informacje o autorze tego skrypty
function Author
{
    Write-Host    "AZ2 Zadanie Analiza GPO"
    Write-Host    ""
    Write-Host    "Author:"
    Write-Host    "Grzegorz Sekuła"
    Write-Host    "Nr indeksu: 17313"
}

#Funkcja odpowiedzialna za wyświetlanie menu
function Show-Menu
{
    Clear-Host
    Write-Host "================ MENU ================"
    Write-Host ""
    Write-Host "        == Obsługa raportów ==        "
    Write-Host "1: Wciśnij '1' aby otrzymać raport SECURITY OPTIONS."
    Write-Host "2: Wciśnij '2' aby otrzymać raport USER RIGHTS ASSIGMENT."
    Write-Host "3: Wciśnij '3' aby otrzymać raport WSUS SETTINGS."
    Write-Host "4: Wciśnij '4' aby otrzymać raport USŁUGI SYSTEMOWE."
    Write-Host "5: Wciśnij '5' aby otrzymać raport WSZYSTKIEGO."
    Write-Host "             == Więcej ==             "
    Write-Host "A: Wciśnij 'A' aby otrzymać informacje o autorze."
    Write-Host "Q: Wciśnij 'Q' aby wyjść."
    Write-Host ""
    Write-Host "======================================"
}

function SecurityOptions
{

}

function UserRightsAssigment
{

}

function WSUSSettings
{

}

function SystemServices
{

}

#Wyświetlenie menu i oczekiwanie na decyzję. Po wybraniu odpowiedniej opcji jest wywoływana odpowiednia funkcja
do
{
    Show-Menu
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
            Author
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
