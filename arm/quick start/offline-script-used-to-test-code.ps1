# @param
$username = "admin@gt1101.onmicrosoft.com"
# @param
$password = "ReverseParol44"

#region string literals
$failure = "Provided account is missing Owner role." 
$success = "Provided account has Owner role." 
#endreginon 

#region body
Write-Output "Enter"

$ErrorActionPreference = 'Stop'

#region find role
$password = ConvertTo-SecureString $password -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($username, $password)

try {
    Connect-AzAccount -Credential $pscredential

    $assignment = Get-AzRoleAssignment -SignInName $username

    foreach ($x in $assignment) { 
        if ($x.RoleDefinitionName -eq "Owner") { 
            $found = $success; 
            break
        } 
        Else {
            $found = $failure 
        } 
    }
}
catch { 
    $found = "Provided account is missing Owner role."
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $found

#endregion
