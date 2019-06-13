# 1.	При помощи WMI перезагрузить все виртуальные машины.
$machines = @( 'Veremeev-VM1', 'Veremeev-VM2', 'Veremeev-VM3' )
$cred = Get-Credential
Get-WmiObject -Class Win32_OperatingSystem -ComputerName $machines -Credential $cred | 
Invoke-WmiMethod -Name Reboot


# 2.	При помощи WMI просмотреть список запущенных служб на удаленном компьютере. 
Get-WmiObject -Class Win32_Service -ComputerName 'Veremeev-VM1' -Credential $cred | 
Where-Object {$_.State -eq 'Running'} |
Format-Table

# 3.	Настроить PowerShell Remoting, для управления всеми виртуальными машинами с хостовой.
Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'Veremeev-VM1, Veremeev-VM2, Veremeev-VM3'

# 4.	Для одной из виртуальных машин установить для прослушивания порт 42658. Проверить работоспособность PS Remoting.
### изменение порта для подключения на VM3
Set-Item WSMan:\localhost\Listener\*\Port -Value 42658

### продключение к VM3 с хоста
Enter-PSSession -ComputerName Veremeev-VM3 -Credential $cred -Port 42658

# 5.	Создать конфигурацию сессии с целью ограничения использования всех команд, кроме просмотра содержимого дисков.
### создание конфигурации сессии на VM1
New-PSSessionConfigurationFile -Path training.pssc `
-VisibleCmdlets Get-ChildItem, Get-Item `
-VisibleProviders FileSystem `
-SessionType RestrictedRemoteServer

$cred = Get-Credential
Register-PSSessionConfiguration -Name Training -Path training.pssc `
-RunAsCredential $cred -ShowSecurityDescriptorUI

### подключение с хоста
$cred = Get-Credential
Enter-PSSession Veremeev-VM1 -ConfigurationName Training -Credential $cred


