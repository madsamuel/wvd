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
        # Connect-AzAccount -Credential $pscredential

        $assignment = Get-AzRoleAssignment -SignInName $username

        foreach ($x in $assignment) { 
            if ($x.RoleDefinitionName -eq "Owner") 
            { 
                $found = $success; 
                $DeploymentScriptOutputs['text'] = $success
                break;
            }         
        }
    }
    catch { 
        $found = "Provided credentials are incorrect."
    }
    #endregion

    $DeploymentScriptOutputs['text'] = $found
  
#endregion
