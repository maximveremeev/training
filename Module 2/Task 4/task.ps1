# 1.	Вывести список всех классов WMI на локальном компьютере. 
Get-WmiObject -List | Select-Object Name

# 2.	Получить список всех пространств имён классов WMI. 
Get-WmiObject -Namespace Root -Class __Namespace |
Select-Object -Property Name

# 3.	Получить список классов работы с принтером.
Get-WmiObject -Recurse -List | 
Where-Object { $_.Name -like '*printer*' }

# 4.	Вывести информацию об операционной системе, не менее 10 полей.
Get-WmiObject -Class Win32_OperatingSystem | 
Select-Object BuildNumber, BuildType, SystemDirectory, SerialNumber, Version, LocalDateTime, Locale, OSArchitecture, OSLanguage, OSType

# 5.	Получить информацию о BIOS.
Get-WmiObject -Class Win32_BIOS

# 6.	Вывести свободное место на локальных дисках. На каждом и сумму.
$sum = 0;
Get-WmiObject -Class Win32_LogicalDisk |
ForEach-Object {
    "$($_.DeviceID) $([Math]::Round($_.FreeSpace / 1GB)) GB"
    $sum += $_.FreeSpace
}
"$([Math]::Round($sum / 1GB))GB"


# 7.	Написать сценарий, выводящий суммарное время пингования компьютера
#       (например 10.0.0.1) в сети.
param(
    [int] $count = 4
)

$sum = 0
for ([int] $i = 0; $i -lt $count; $i++) {
    $ping = Get-WmiObject Win32_PingStatus -Filter "address='8.8.8.8'"
    $sum += $ping.ResponseTime
}
"$sum ms"


# 8.	Создать файл-сценарий вывода списка установленных программных продуктов в виде таблицы с полями Имя и Версия.
Get-WmiObject -Class Win32_Product | 
Format-Table Name, Version

# 9.	Выводить сообщение при каждом запуске приложения MS Word.
Register-wmievent `
–query "select * from __instancecreationevent within 5 where TargetInstance isa 'Win32_Process' and TargetInstance.Name = 'winword.exe'"  `
–action { "Word $(Get-Date)" }