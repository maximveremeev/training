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