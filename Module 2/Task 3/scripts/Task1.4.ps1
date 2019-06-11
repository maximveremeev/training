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
