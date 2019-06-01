# 1.	Просмотреть содержимое ветви реeстра HKCU
Get-ChildItem HKCU:

# 2.	Создать, переименовать, удалить каталог на локальном диске
New-Item -Type directory training
Rename-Item training expert
Remove-Item expert

# 3.	Создать папку C:\M2T2_ФАМИЛИЯ. Создать диск ассоциированный с папкой 
# C:\M2T2_ФАМИЛИЯ.
New-Item -Type directory C:\M2T2_Veremeev
New-PSDrive -Name M2T2 -Root C:\M2T2_Veremeev\ -PSProvider FileSystem

# 4.	Сохранить в текстовый файл на созданном диске список запущенных(!) служб. 
#       Просмотреть содержимое диска. Вывести содержимое файла в консоль PS.
Get-Service | Where-Object { $_.Status -eq "Running" } | Out-File M2T2:\services.log
Get-ChildItem M2T2:\
Get-Content M2T2:\services.log

# 5.	Просуммировать все числовые значения переменных текущего сеанса.
$sum = 0;
Get-Variable -Exclude sum | Where-Object { $_.Value -is [int] } | ForEach-Object { $sum += $_.Value}
Out-Host -InputObject $sum

# 6.	Вывести список из 6 процессов занимающих дольше всего процессор.
Get-Process | Sort-Object CPU -Descending | Select-Object -First 6

# 7.	Вывести список названий и занятую виртуальную память (в Mb) каждого процесса, 
#       разделённые знаком тире, при этом если процесс занимает более 100Mb – 
#       выводить информацию красным цветом, иначе зелёным.
Get-Process | ForEach-Object {
    $color = "green"
    if ( $_.VM -gt 100MB) {
        $color = "red"
    }   
    Write-Host $_.Name, $([Math]::Round($_.VM / 1MB)) -Separator " - " -BackgroundColor $color 
}

# 8.	Подсчитать размер занимаемый файлами в папке C:\ (и во всех подпапках) 
#       за исключением файлов *.tmp
[int64]$sum = 0;
Get-ChildItem -Path C:\ -Exclude "*.tmp" -Recurse -File | ForEach-Object { $sum += $_.Length }
Out-Host -InputObject $sum

# 9.	Сохранить в CSV-файле информацию о записях одной ветви реестра HKLM:\SOFTWARE\Microsoft.
Get-ChildItem HKLM:\SOFTWARE\Microsoft | Export-Csv M2T2:\reestr.csv

# 10.	Сохранить в XML -файле историческую информацию о командах выполнявшихся 
#       в текущем сеансе работы PS.
Get-History | Export-Clixml M2T2:\history.xml

# 11.	Загрузить данные из полученного в п.10 xml-файла и вывести в виде списка 
#       информацию о каждой записи, в виде 5 любых (выбранных Вами) свойств.
Import-Clixml M2T2:\history.xml | 
Select-Object Id, CommandLine, ExecutionStatus, StartExecutionTime, EndExecutionTime

# 12.	Удалить созданный диск и папку С:\M2T2_ФАМИЛИЯ
Remove-PSDrive M2T2:
Remove-Item C:\M2T2_Veremeev -Recurse