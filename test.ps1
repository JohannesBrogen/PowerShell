<#
.SYNOPSIS
Collection of PowerShell test scripting
.DESCRIPTION
Some description
.PARAMETER args
write output flags
.EXAMPLE
.\test.ps1
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
Get-RandomMessage
#Endregion 

#Region Get information about the computer
Get-CimInstance win32_operatingsystem | Select-Object -Property Name, SerialNumber | Format-List
Get-CimInstance Win32_ComputerSystem | Format-List
#Endregion

#Region variable scopes
function Display-VariableScope {
    Write-Output $var
    Write-Output $global:globalvar
    Write-Output $script:scriptvar
    Write-Output $private:privatevar

    $functionvar = "function var"
    $private:functionprivatevar = "private function var"
    $global:functionglobalvar = "global function var"
}

$var = 'This is $var'
Get-Variable var -Scope local
$global:globalvar = "global var"
$script:scriptvar = "script var"
$private:privatevar = "private var"

Display-VariableScope
$functionprivatevar
$functionglobalvar
#Endregion

#Region For-each object
ForEach-Object -InputObject (1..10) {
    $_
} | Measure-Object

$object = [ordered]@{
    one = 1
    two = 2
    three = 3
}

ForEach-Object -InputObject $object {
    $_
}
#Endregion