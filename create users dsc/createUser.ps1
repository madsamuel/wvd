param(
      [string]$userName,
      [string]$domainName,  
      [string]$passWord
)

function Ensure-ModuleExists
<#
	.SYNOPSIS
		Ensures a specific PowerShell module exists.
	
	.DESCRIPTION
    
        Ensures a specific PowerShell module exists.
	
		Notably, this command:
        - Looks for the module (with the minimum version, if supplied)
		- Installs that module

	.EXAMPLE
		PS C:\> Ensure-ModuleExists "ActiveDirectory"
        Module exists: ActiveDirectory

#>
{
    Param (
        [Parameter(Mandatory=$True, Position=0, HelpMessage="PowerShell module name")]
        [String]$Name,
        [Parameter(Mandatory=$False, Position=1, HelpMessage="PowerShell module minimum version")]
        [String]$MinimumVersion
    )

    Process
    {
        $found = $false;
        $modules = Get-Module $Name -ListAvailable

        if ($modules)
        {
            if ($MinimumVersion)
            {
                if ($modules | where { $_.Version -ge $MinimumVersion })
                {
                    $found = $true
                }
            }
            else
            {
                $found = $true
            }
        }

        if (!$found)
        {
            Write-Host "Installing $Name"

            try
            {
                Install-Module $Name -AllowPrerelease -SkipPublisherCheck -Force -Confirm:$false | Out-Null
            }
            catch
            {
                Write-Host "Caught exception: $($_.Exception.Message)"
                Install-Module $Name -SkipPublisherCheck -Force -Confirm:$false | Out-Null
            }
        }
        else
        {
            Write-Host "Module exists: $Name"
        }
    }
}


function Install-Prerequisites
{
<#
	.SYNOPSIS
		Enables all features needed to run the Join-AzStorageAccountForAuth cmdlet
	
	.DESCRIPTION
		Enables all features needed to run the Join-AzStorageAccountForAuth cmdlet
	
		Notably, this command ensures that:
		
        - ActiveDirectory module is available
        - Az module is available

	.EXAMPLE
		PS C:\> Install-Prerequisites
#>
    Param (
    )

    Process
    {
        Ensure-ModuleExists "ActiveDirectory"
        
        # Below is removed to not override private PowerShell Az.Storage installation.
        # Ensure-ModuleExists "Az"
    }
}

#Extract FSlogix agent 
write-host "Create user..."

# Import-Module ActiveDirectory -Force

Install-Prerequisites

New-ADUser `
-SamAccountName $userName `
-UserPrincipalName $($userName + "@" + $domainName) `
-Name "$userName" `
-GivenName $userName `
-Surname $userName `
-Enabled $True `
-ChangePasswordAtLogon $True `
-DisplayName "$userName" `
-AccountPassword (convertto-securestring $passWord -AsPlainText -Force)

write-host "Create user completed."


