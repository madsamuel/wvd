param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

$found
$DeploymentScriptOutputs = @{}

#region body
$ErrorActionPreference = 'Stop'

    #region credential 
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
    #endregions

    #region connetc and test roles
    
try {
    $sess = New-PSSession -ComputerName "AdvM" -Credential $pscredential 

    $output = Invoke-command  -session $sess -scriptblock {
        [Net.ServicePointManager]::SecurityProtocol = "tls12"
        Install-Module AzureAD -Force
        Import-Module AzureAD -Force 

        Write-Output "Start script."    
        
        try {
            Connect-AzureAD -Credential $Using:pscredential -
            Write-Output "Authenticated."        
        }
        catch
        {
            Write-Output "Incorrect credentials."
        }

        try {
                Update-AzureADSignedInUserPassword -CurrentPassword $Using:securePassword -NewPassword $Using:securePassword 
                Write-Output "`n Password is correct."
            }
        catch {
            Write-Output "`nPassword is incorrect."
        }
    } 

    Disconnect-PSSession -session $sess 

    $Events = Select-String -InputObject $output -Pattern 'Password is correct'
    
    if ($Events -like "*Password is correct*") {
        # write to outpot obj
        # Write-Output "Good"    
        $found
    } else {
        # Write-Output "Bad"    
        $found
    }
}
catch {
    #Write-Output "Bad"   
    $found 
}
    
    $DeploymentScriptOutputs['text'] = $found
  
#endregion
