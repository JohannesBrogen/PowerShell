<#
.SYNOPSIS
Collection of PowerShell test scripting
.DESCRIPTION
Some description
.PARAMETER args
write output flags
.EXAMPLE
.\test.ps1 -verbose, -debug
#>

#Region try-catch
try {
    Get-Content -Path y:\this\path\does\not\exist.txt -ErrorAction Stop
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output "Dun goofed: $ErrorMessage"
    Write-Host -ForegroundColor Blue -BackgroundColor White $_.Exception
}
#Endregion

#Region function with different output
function Get-RandomMessage {
    [CmdletBinding()]
    Param([parameter(ValueFromRemainingArguments=$true)][string[]] $args)

    Write-Verbose "Generating a random number"
    $number = Get-Random -Maximum 10
    Write-Verbose "Number is $number"

    Write-Debug "Start of switch statement"
    switch ($number) {
        {$_ -lt 4} {Write-Output "Heisann!"; Write-Debug "Less than 4"}
        {$_ -ge 4 -and $_ -lt 7} {Write-Output "Hoppsann!"; Write-Debug "4-6"}
        Default {Write-Output "Fallerallera!"; Write-Debug "Default"}
    }
}
#Endregion 