param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

#region string literals
$failure = "Provided account is missing Owner role." 
$success = "Provided account has Owner role." 
#endregion 

#region body
$ErrorActionPreference = 'Stop'

    #region authenticate
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
    #endregion

    #region connetc and test roles
    try {
        Connect-AzAccount -Credential $pscredential

        $assignment = Get-AzRoleAssignment -SignInName $username

        foreach ($x in $assignment) { 
            if ($x.RoleDefinitionName -eq "Owner") 
                { $found = $success; break} 
            Else
            {$found = $failure } 
        }
    }
    catch { 
        $found = "Provided account is missing Owner role."
    }
    #endregion

    #region output
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['text'] = $found
    #endregion
#endregion
