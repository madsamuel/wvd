#below code does not work in PS core so change the terminal ot powershell

#region import modules
Import-Module AzureAD -Global
#endregion

#region parameters for Runbook
$usernameAAD = "admin@gt1101.onmicrosoft.com"
$passwordAAD = "ReverseParol44"
$subid = "5c14a947-e099-4b3f-932e-6e836da92be6"
#endregion

#region credentials
Write-Output "Prep AAD credential." 
$securePassword = ConvertTo-SecureString $passwordAAD -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($usernameAAD , $securePassword)
Write-Output "Done AAD credential."
#endregion

#region connet to Azure
Try {
    Write-Output "Try to connect Azure."
    Connect-AzAccount -Environment 'AzureCloud' -Credential $pscredential
    
    Write-Output "Connected to Azure."

    Write-Output "Select subscription."
    Select-AzSubscription -SubscriptionId $subId
    
    # Write-Output "Create RG"
    # New-AzResourceGroup -Name RG01 -Location "South Central US"
}
Catch {
    Write-Output "Throwing..."
    throw  "Please authenticate to Azure Login-AzAccount or Connect-AzAccount."
    Write-Output "Catching..."
}
#endregion

#region connect to Azure and check if Owner
    # The password property of the credentials object is cleared after the call for to Connect-AzAccount hece regenerating the,
    Write-Output "Prep AAD credential." 
    $securePassword = ConvertTo-SecureString $passwordAAD -AsPlainText -Force
    # Test # $usernameAAD = "user001@gt1101.onmicrosoft.com"
    $pscredential = New-Object System.Management.Automation.PSCredential($usernameAAD , $securePassword)
    Write-Output "Done AAD credential."

    Try {
        Write-Output "Try to connect AzureAD."
        Connect-AzureAD -Credential $pscredential
        
        Write-Output "Connected to AzureAD."
        
        # get user object 
        $userInAzureAD = Get-AzureADUser -Filter "UserPrincipalName eq `'$usernameAAD`'"

        $isOwner = Get-AzRoleAssignment -ObjectID $userInAzureAD.ObjectId | Where-Object { $_.RoleDefinitionName -eq "Owner"}
        
        if ($isOwner.RoleDefinitionName -eq "Owner") {
            Write-Output $($usernameAAD + " has Owner role assigned")        
        } 
        else {
            Write-Output "Missing Owner role."   
            Throw
        }
    }
    Catch {    
        Write-Output  $($usernameAAD + " does not have Owner role assigned")
    }
#endregion

#region connect to Azure and check if admin on Azure AD 
    # The password property of the credentials object is cleared after the call for to Connect-AzAccount hece regenerating the,
    Write-Output "Prep AAD credential." 
    $securePassword = ConvertTo-SecureString $passwordAAD -AsPlainText -Force
    # Test # $usernameAAD = "user001@gt1101.onmicrosoft.com"
    $pscredential = New-Object System.Management.Automation.PSCredential($usernameAAD , $securePassword)
    Write-Output "Done AAD credential."

    Try {
        # this depends on the previous segment completeing 
        $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Company Administrator'}
        $isMember = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $usernameAAD}
        
        if ($isMember.UserType -eq "Member") {
            Write-Output $($usernameAAD + " has " + $role.DisplayName + " role assigned")        
        } 
        else {
            Write-Output "Missing Owner role."   
            Throw
        }
    }
    Catch {    
        Write-Output  $($usernameAAD + " does not have " + $role.DisplayName + " role assigned")
    }
#endregion

#region check Microsoft.DesktopVirtualization resource provider has been registerred and register if not 
    $wvdResourceProviderName = "Microsoft.DesktopVirtualization"
    try {
        Get-AzResourceProvider -ListAvailable | Where-Object { $_.ProviderNamespace -eq $wvdResourceProviderName  }
        Write-Output  $($wvdResourceProviderName + " is registerred!" )
    }
    Catch {
        Write-Output  $("Resource provider " + $wvdResourceProviderName + " is not registerred")
        try {
            Write-Output  $("Registerring " + $wvdResourceProviderName )
            Register-AzResourceProvider -ProviderNamespace $wvdResourceProviderName
            Write-Output  $("Registration of " + $wvdResourceProviderName + " completed!" )
        } 
        catch {
            Write-Output  $("Registerring " + $wvdResourceProviderName + " has failed!" )
        }
    }
#endregion

#region check VNET sees domain controller 
    $domainName = "gt1101.onmicorsoft.com"    

    $domainControler = "advm"    
    $VNET = "adVnet"

try {
    Resolve-DnsName -Name $domainName
    Write-Output  $($wvdResourceProviderName + " is registerred!" )
}
Catch {
    Write-Output  $("Resource provider " + $wvdResourceProviderName + " is not registerred")
    try {
        Write-Output  $("Registerring " + $wvdResourceProviderName )
        Register-AzResourceProvider -ProviderNamespace $wvdResourceProviderName
        Write-Output  $("Registration of " + $wvdResourceProviderName + " completed!" )
    } 
    catch {
        Write-Output  $("Registerring " + $wvdResourceProviderName + " has failed!" )
    }
}
#endregion