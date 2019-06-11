###############################################################################################
# 1.	Создайте сценарии *.ps1 для задач из labwork 2, 
#     проверьте их работоспостобность. Каждый сценарий должен иметь параметры.
#     1.1.	Сохранить в текстовый файл на диске список запущенных(!) служб. 
#           Просмотреть содержимое диска. Вывести содержимое файла в консоль PS.
param(
    [ValidateScript( {Test-Path $_} )]
    [string] $Path = '.',

    [string] $LogName = 'services.log'
)

[string] $FilePath = Join-Path $Path $LogName
[void] (Get-Service | Where-Object { $_.Status -eq "Running" } | Out-File -FilePath $FilePath)
Get-ChildItem $FilePath
Get-Content $FilePath



###############################################################################################
#     1.2.	Просуммировать все числовые значения переменных среды Windows. (Параметры не нужны)
$sum = 0;
Get-Variable -Exclude sum | 
Where-Object { $_.Value -is [int] } | 
ForEach-Object { $sum += $_.Value}
$sum



###############################################################################################
#     1.3.	Вывести список из 10 процессов занимающих дольше всего процессор. 
#           Результат записывать в файл.
param(
    [ValidateScript( {Test-Path $_} )]
    [string] $Path = '.',
    
    [string] $LogName = 'processes.log',
    
    [ValidateRange(0, [int]::MaxValue)]
    [int] $Count = 10
)

$FilePath = Join-Path $Path $LogName

Get-Process | 
Sort-Object CPU -Descending | 
Select-Object -First $Count | 
Out-File $FilePath 

#       1.3.1.	Организовать запуск скрипта каждые 10 минут
$jTrig = New-JobTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10) -RepetitionDuration ([TimeSpan]::MaxValue) 
$cred = Get-Credential mveremeev
$jOpt = New-SheduledJobOption -RunElevated
Register-ScheduledJob -Name Log -FilePath 'task1.3.ps1' -Trigger $jTrig -Credential $cred -ScheduledJobOption $jOpt



###############################################################################################
#     1.4.	Подсчитать размер занимаемый файлами в папке (например C:\windows) 
#            за исключением файлов с заданным расширением(напрмер .tmp)
param(
    [ValidateScript( {Test-Path $_} )]
    [string] $Path = '.',
        
    [string] $Exclude = ''
)


[string] $SearchPath = Join-Path $Path '*'
[int64] $sum = 0;

Get-ChildItem -Path $SearchPath -Exclude $Exclude -File | 
ForEach-Object { $sum += $_.Length }

$sum



###############################################################################################
#     1.5.	Создать один скрипт, объединив 3 задачи:
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^secupdate$|^reg$')]
    [string] $LogType
)

$UpdateFile = 'secupdate.txt'
$RegFile = 'reg.txt'


#         1.5.1.  Сохранить в CSV-файле информацию обо всех обновлениях безопасности ОС.
Get-HotFix -Description 'Security Update' | 
Export-Csv $UpdateFile


#         1.5.2.  Сохранить в XML-файле информацию о записях одной ветви реестра HKLM:\SOFTWARE\Microsoft.
Get-ChildItem HKLM:\SOFTWARE\Microsoft | 
Export-Clixml $RegFile


#         1.5.3.  Загрузить данные из полученного в п.1.5.1 или п.1.5.2 файла и 
#                 вывести в виде списка  разным разными цветами
switch ($LogType) {
    'secupdate' {  
        $objs = Import-Csv $UpdateFile
        [int] $i = 0
        foreach ($obj in objs) {
            if ($i % 2) { $color = 'red' } 
            else { $color = 'green' }
            Write-Host $obj.CSName, $obj.Description, $obj.HotFixId, $obj.InstalledOn -BackgroundColor $color
            $i++
        } 
    }
    'reg' {         
        $objs = Import-Clixml $RegFile
        [int] $i = 0
        foreach ($obj in objs) {
            if ($i % 2) { $color = 'red' } 
            else { $color = 'green' }
            Write-Host $obj.Name, $obj.SubKeyCount, $obj.ValueCount -BackgroundColor $color
            $i++
        }  
    }
}


###############################################################################################
# 2.	Работа с профилем
#     2.1.	Создать профиль
New-Item -ItemType file -Path $profile -force

#     2.2.	В профиле изненить цвета в консоли PowerShell
$param = @"
    (Get-Host).UI.RawUI.ForegroundColor = 'red'
    (Get-Host).UI.RawUI.BackgroundColor = 'black'
"@
$param >> $profile

#     2.3.	Создать несколько собственный алиасов
$param = @"
    Set-Alias -Name na -Value Get-NetAdapter
    Set-Alias -Name gj -Value Get-Job
"@
$param >> $profile

#     2.4.	Создать несколько констант
$param = @"
    Set-Variable MyName -option Constant -value 'Max'
    Set-Variable PI -option Constant -value 3.14
"@
$param >> $profile

#     2.5.	Изменить текущую папку
$param = @"
    Set-Location C:\
"@
$param >> $profile

#     2.6.	Вывести приветсвие
$param = @"
    Write-Output 'Hello'
"@
$param >> $profile

#     2.7.	Проверить применение профиля

###############################################################################################
# 3.	Получить список всех доступных модулей
Get-Module -All
