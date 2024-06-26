begin {
    # Enable verbose output
    $Verbose = $true

    $OldVerbose = $VerbosePreference
    if ($Verbose) {    
        $VerbosePreference = "continue"
    }

    # List of app names to remove
    $AppsToRemove = @(
        "Microsoft.MicrosoftSolitaireCollection",
        "SumBS",
        "Microsoft.BingWeather"
    )

    # Counts successfull app remove
    [int]$AppxCount = 0
    #[int]$AppxProvisionedCount = 0

    function RemovePackage {    
        try {
            $Package = Get-AppxPackage -AllUsers -Name $App | Select-Object -ExpandProperty PackageFullName

            if (!([string]::IsNullOrEmpty($Package))) {
                try {
                    Remove-AppPackage -Package $Package -AllUsers -ErrorAction Stop
                    Write-Verbose "- AppxPackage removed: $Package"
                }
                catch {
                    throw "Unable to remove AppxPackage for: $App"
                }
            } else {
                throw "Unable to find AppxPackage for: $App"
            }
        }
        catch {
            throw $_
        }
    }
    <#
    function RemoveProvisionedPackage {
        try {
            $ProvisionedPackage = Get-AppxProvisionedPackage -Online | where-object {$_.DisplayName -like $App} | Select-Object -ExpandProperty PackageName

            if (!([string]::IsNullOrEmpty($ProvisionedPackage))) {
                try {
                    Remove-AppxProvisionedPackage -PackageName $ProvisionedPackage -AllUsers -Online -ErrorAction Stop
                    Write-Verbose "- AppxProvionedPackage removed: $ProvisionedPackage"
                }
                catch {
                    throw "Unable to remove AppxProvisionedpackage: $App"
                }
            } else {
                throw "Unable to find AppxProvisionedpackage: $App"
            }
        }
        catch {
            throw $_
        }
       
    }
    #>
}


Process {
    if ($($AppsToRemove.Count) -ne 0) {
        Write-Host -ForegroundColor Yellow "Apps to remove:"
        $AppsToRemove
        
        # List of successfull or failed removals
        $SuccessAppx = New-Object -TypeName System.Collections.ArrayList
        $FailedAppx = New-Object -TypeName System.Collections.ArrayList

        #$SuccessAppxProvisioned = New-Object -TypeName System.Collections.ArrayList
        #$FailedAppxProvisioned = New-Object -TypeName System.Collections.ArrayList
        

        foreach ($App in $AppsToRemove) {
            Write-Verbose "Searching for $App"
            
            try {
                RemovePackage $App -ErrorAction Stop
                $SuccessAppx.AddRange(@($App))
                $AppxCount ++
                Write-Verbose "- Current AppxPackage Count: $AppxCount"
            }
            catch {
                Write-Verbose "--- AppxPackage Error ---"
                Write-Host -ForegroundColor Red "Error: " $_
                $FailedAppx.AddRange(@($App))
            }

            # Seems the RemovePackageFunction also removes it from the provisioned list as well
            <#
            try {
                RemoveProvisionedPackage $App -ErrorAction Stop
                $SuccessAppxProvisioned.AddRange(@($App))
                $AppxProvisionedCount ++
                Write-Verbose "- Current AppxProvisionedPackage Count: $AppxProvisionedCount"
            }
            catch {
                Write-Verbose "--- AppxProvisionedPackage Error ---"
                Write-Host -ForegroundColor Red "Error: " $_
                $FailedAppxProvisioned.AddRange(@($App))
            }
            #>
            
        }

        # AppxPackages summary
        Write-Verbose "Final AppxCount: $AppxCount"
        if (!([string]::IsNullOrEmpty($SuccessAppx))) {
            Write-Host -ForegroundColor Yellow "AppxPackages removed:"
            $SuccessAppx
        }
        if (!([string]::IsNullOrEmpty($FailedAppx))) {
            Write-Host -ForegroundColor Red "Were unable to remove the following AppxPackages:"
            $FailedAppx
        } else {
            Write-Host -ForegroundColor Green "All AppxPackages removed"
        }

        # AppxProvisionedPackages summary
        <#
        Write-Verbose "Final AppxProvisionedCount: $AppxProvisionedCount"
        if (!([string]::IsNullOrEmpty($SuccessAppxProvisioned))) {
            Write-Host -ForegroundColor Yellow "AppxProvisionedPackages removed:"
            $SuccessAppxProvisioned
        }
        if (!([string]::IsNullOrEmpty($FailedAppxProvisioned))) {
            Write-Host -ForegroundColor Red "Were unable to remove the following AppxProvisionedPackages:"
            $FailedAppxProvisioned
        } else {
            Write-Host -ForegroundColor Green "All AppxProvisionedPackages removed"
        }
        #>

    }  else {
        Write-Host -ForegroundColor Red "No listed apps"
    }
}

End {
    $VerbosePreference = $OldVerbose
}