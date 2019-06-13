# 1.	Для каждого пункта написать и выполнить соответсвующий скрипт автоматизации администрирования:
# 1.1.	Вывести все IP адреса вашего компьютера (всех сетевых интерфейсов)
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPENABLED=TRUE | 
Select-Object IpAddress

# 1.2.	Получить mac-адреса всех сетевых устройств вашего компьютера.
Get-WmiObject -Class Win32_NetworkAdapter | 
Select-Object MacAddress

# 1.3.	На всех виртуальных компьютерах настроить (удалённо) получение адресов с DHСP.
$machines = @( 'Veremeev-VM1', 'Veremeev-VM2', 'Veremeev-VM3' )
$cred = Get-Credential

Get-WmiObject -Class Win32_NetworkAdapterConfiguration `
-ComputerName $machines -Credential $cred `
-Filter 'IpEnabled=TRUE AND DHCPEnabled=FALSE' | 
Invoke-WmiMethod -Name EnableDHCP

# 1.4.	Расшарить папку на компьютере
New-SmbShare -Name "Share" -Path "c:\share" -FullAccess Administrator


# 1.5.	Удалить шару из п.1.4
Remove-SmbShare Share -Confirm

# 1.6.	Скрипт входными параметрами которого являются Маска подсети и два ip-адреса. 
#       Результат  – сообщение (ответ) в одной ли подсети эти адреса.
param(
    [Parameter(Mandatory=$true)]
    [ipaddress] $IP1,

    [Parameter(Mandatory=$true)]
    [ipaddress] $IP2,

    [ValidateScript({
        [string] $bit_mask = '' 
        foreach ($byte in $_.GetAddressBytes()) {
            $bit_mask += [System.Convert]::ToString($byte, 2).PadLeft(8, '0')
        } 
        return $bit_mask -match '^[1]+[0]+$'
    })]
    [Parameter(ParameterSetName='prefix', Mandatory=$false)]
    [Parameter(ParameterSetName='mask', Mandatory=$true)]
    [ipaddress] $Mask,

    [Parameter(ParameterSetName='mask', Mandatory=$false)]
    [Parameter(ParameterSetName='prefix', Mandatory=$true)]
    [ValidateRange(1,31)]
    [int] $Prefix
)

function Convert-ToBin([ipaddress] $ip) {
    [string] $ip_bin = '' 
    foreach ($byte in $ip.GetAddressBytes()) {
        $ip_bin += [System.Convert]::ToString($byte, 2).PadLeft(8, '0')
    } 
    return $ip_bin
}

function Check-Subnet([ipaddress] $ip1, [ipaddress] $ip2, [int] $prefix) {
    $ip1_bin = Convert-ToBin($ip1)
    $ip2_bin = Convert-ToBin($ip2)
    return $ip1_bin.substring(0, $prefix) -eq $ip2_bin.substring(0, $prefix)
}



# compute Prefix from Mask
if ($Mask) {
    $mask_bin = Convert-ToBin($Mask)
    $Prefix = ([regex]::Matches($mask_bin, '1')).count
}



$result = Check-Subnet -ip1 $IP1 -ip2 $IP2 -prefix $Prefix
if ($result) {
    "IP's from one subnet" 
} else {
    "IP's from different subnet"
}


############################################################################
# 2.	Работа с Hyper-V
# 2.1.	Получить список коммандлетов работы с Hyper-V (Module Hyper-V)
Get-Command -Module Hyper-V

# 2.2.	Получить список виртуальных машин 
Get-VM
<#
    Name         State   CPUUsage(%) MemoryAssigned(M) Uptime           Status             Version
    ----         -----   ----------- ----------------- ------           ------             -------
    Veremeev_VM1 Running 0           532               01:06:26.0760000 Operating normally 9.0
    Veremeev_VM2 Running 0           530               01:06:25.0220000 Operating normally 9.0
    Veremeev_VM3 Running 0           536               01:06:23.0620000 Operating normally 9.0
#>


# 2.3.	Получить состояние имеющихся виртуальных машин
Get-VM | Select-Object Name, State
<#
    Name           State
    ----           -----
    Veremeev_VM1 Running
    Veremeev_VM2 Running
    Veremeev_VM3 Running
#>


# 2.4.	Выключить виртуальную машину
Stop-VM Veremeev_VM1
Get-VM
<#
    Name         State   CPUUsage(%) MemoryAssigned(M) Uptime           Status             Version
    ----         -----   ----------- ----------------- ------           ------             -------
    Veremeev_VM1 Off     0           0                 00:00:00         Operating normally 9.0
    Veremeev_VM2 Running 0           530               01:10:35.6720000 Operating normally 9.0
    Veremeev_VM3 Running 0           536               01:10:33.7120000 Operating normally 9.0
#>


# 2.5.	Создать новую виртуальную машину

$VMName = 'Veremeev_VM4'
$vhd = New-VHD -Path "C:\VHDs\$VMName.vhdx" -Dynamic -SizeBytes 60GB
$switch = New-VMSwitch -name PrivateSwitch -SwitchType Private


$VMParam = @{
    Name = $VMName
    MemoryStartupBytes = 1GB
    Generation = 2
    Switch = $switch.Name
    VHDPath = $vhd.Path
}

New-VM  @VMParam
<#
    Name         State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
    ----         ----- ----------- ----------------- ------   ------             -------
    Veremeev_VM4 Off   0           0                 00:00:00 Operating normally 9.0
#>


# 2.6.	Создать динамический жесткий диск
New-VHD -Path 'C:\VHDs\Veremeev_VM4.vhdx' -Dynamic -SizeBytes 100GB
<#
    ComputerName            : IT3
    Path                    : C:\VHDs\Veremeev_VM4.vhdx
    VhdFormat               : VHDX
    VhdType                 : Dynamic
    FileSize                : 4194304
    Size                    : 107374182400
    MinimumSize             :
    LogicalSectorSize       : 512
    PhysicalSectorSize      : 4096
    BlockSize               : 33554432
    ParentPath              :
    DiskIdentifier          : E5DE3935-5B62-4AAC-9FB9-20FD6EA4BB23
    FragmentationPercentage : 0
    Alignment               : 1
    Attached                : False
    DiskNumber              :
    IsPMEMCompatible        : False
    AddressAbstractionType  : None
    Number                  :
#>

# 2.7.	Удалить созданную виртуальную машину
Remove-VM Veremeev_VM4 -Confirm
