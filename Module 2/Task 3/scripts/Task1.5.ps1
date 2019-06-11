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
