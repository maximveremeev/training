$sum = 0;
Get-Variable -Exclude sum | 
Where-Object { $_.Value -is [int] } | 
ForEach-Object { $sum += $_.Value}
$sum