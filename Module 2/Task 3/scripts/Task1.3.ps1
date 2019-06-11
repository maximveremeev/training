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
# $jTrig = New-JobTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10) -RepetitionDuration ([TimeSpan]::MaxValue) 
# $cred = Get-Credential mveremeev
# $jOpt = New-SheduledJobOption -RunElevated
# Register-ScheduledJob -Name Log -FilePath 'task1.3.ps1' -Trigger $jTrig -Credential $cred -ScheduledJobOption $jOpt