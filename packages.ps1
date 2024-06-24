begin {
    # Enable verbose output
    $Verbose = $true

    $OldVerbose = $VerbosePreference
    if ($Verbose) {    
        $VerbosePreference = "continue"
    }

    # List of app names to find
    $AppsToFind = @(
        "Microsoft.WindowsCalculator",
        "Microsoft.ZuneMusic",
        "SumBS",
        "Microsoft.BingWeather"
    )

    # Counts successfull app lookups
    [int]$AppxCount = 0
    [int]$AppxProvisionedCount = 0

    # $AppProvisionedPackages = Get-AppxProvisionedPackage -Online

    function FindPackage {    
        try {
            Write-Verbose "Searching for $App"
            $Package = Get-AppxPackage -Name $App | Select-Object -ExpandProperty PackageFullName

            if (!([string]::IsNullOrEmpty($Package))) {
                Write-Verbose "AppxPackage found: $Package"
            } else {
                throw "Unable to find AppxPackage: $App"
            }
        }
        catch {
            throw $_
        }
    }

    function FindProvisionedPackage {
        try {
            $ProvisionedPackage = Get-AppxProvisionedPackage -Online | where-object {$_.DisplayName -like $App} | Select-Object -ExpandProperty PackageName

            if (!([string]::IsNullOrEmpty($ProvisionedPackage))) {
                Write-Verbose "AppxProvionedPackage found: $Package"
            } else {
                throw "Unable to find AppxProvisionedpackage: $App"
            }
        }
        catch {
            throw $_
        }
       
    }
}

Process {
    if ($($AppsToFind.Count) -ne 0) {
        Write-Host -ForegroundColor Yellow "Apps to search for:"
        $AppsToFind
        
        # List of failed removals
        $SuccessAppx = New-Object -TypeName System.Collections.ArrayList
        $SuccessAppxProvisioned = New-Object -TypeName System.Collections.ArrayList
        $FailedAppx = New-Object -TypeName System.Collections.ArrayList
        $FailedAppxProvisioned = New-Object -TypeName System.Collections.ArrayList

        foreach ($App in $AppsToFind) {
            try {
                FindPackage $App -ErrorAction Stop
                $SuccessAppx.AddRange(@($App))
                $AppxCount ++
                Write-Verbose "Current AppCount: $AppxCount"
            }
            catch {
                Write-Verbose "AppxPackage Error"
                Write-Host -ForegroundColor Red "Error: " $_
                $FailedAppx.AddRange(@($App))
            }

            try {
                FindProvisionedPackage $App -ErrorAction Stop
                $SuccessAppxProvisioned.AddRange(@($App))
                $AppxProvisionedCount ++
                Write-Verbose "Current AppCount: $AppxProvisionedCount"
            }
            catch {
                Write-Verbose "AppxProvisionedPackage Error"
                Write-Host -ForegroundColor Red "Error: " $_
                $FailedAppxProvisioned.AddRange(@($App))
            }
            
        }

        # AppxPackages summary
        Write-Verbose "Final AppxCount: $AppxCount"
        if (!([string]::IsNullOrEmpty($SuccessAppx))) {
            Write-Host -ForegroundColor Yellow "AppxPackages found:"
            $SuccessAppx
        }
        if (!([string]::IsNullOrEmpty($FailedAppx))) {
            Write-Host -ForegroundColor Red "Were unable to find the following AppxPackages:"
            $FailedAppx
        } else {
            Write-Host -ForegroundColor Green "All AppxPackages found"
        }

        # AppxPrivisionedPackages summary
        Write-Verbose "Final AppxPrivisionedCount: $AppxProvisionedCount"
        if (!([string]::IsNullOrEmpty($SuccessAppxProvisioned))) {
            Write-Host -ForegroundColor Yellow "AppxProvisionedPackages found:"
            $SuccessAppxProvisioned
        }
        if (!([string]::IsNullOrEmpty($FailedAppxProvisioned))) {
            Write-Host -ForegroundColor Red "Were unable to find the following AppxProvisionedPackages:"
            $FailedAppxProvisioned
        } else {
            Write-Host -ForegroundColor Green "All AppxPrivisionedPackages found"
        }

        # If current processed app count is equal to entire list
        <#Write-Verbose "Comparing amount of apps listed: $($AppsToFind.Count), to current AppCount: $AppCount"
        if ($($AppsToFind.Count) -le $AppCount) {
            Write-Host -ForegroundColor Green "All apps removed"
        } else {
            Write-Host -ForegroundColor Red "Were unable to remove the following AppxPackages:"
            $FailedAppx
            Write-Host -ForegroundColor Red "Were unable to remove the following AppxProvisionedPackages:"
            $FailedAppxProvisioned
        }#>
    }  else {
        Write-Host -ForegroundColor Red "No listed apps"
    }
}

End {
    $VerbosePreference = $OldVerbose
}