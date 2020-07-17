param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

#region string literals
$failure = "Provided account is missing Owner role." 
$success = "Provided account has Owner role." 
$credFailure = "Provided credentials are incorrect."
#endregion 

#region output
$DeploymentScriptOutputs = @{}

#endregion

#region body
$ErrorActionPreference = 'Stop'

    #region authenticate
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
    #endregion

    #region connetc and test roles
    try {
        Connect-AzureAD -Credential $pscredential 
        $found = $success
        #region password reset
        try {
            Update-AzureADSignedInUserPassword -CurrentPassword (ConvertTo-SecureString $password -AsPlainText -Force ) -NewPassword (ConvertTo-SecureString $password -AsPlainText -Force)
            $found = $found + " Password is correct."
        }
        catch {
            $found = $found + " Password is incorrect."
        }
        #endregion
    }
    catch { 
        $found = $failure
    }  
    #endregion

    $DeploymentScriptOutputs['text'] = $found
  
#endregion
