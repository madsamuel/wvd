Param
(
  [string] [Parameter(Mandatory=$true)] $domainName = "gt1101.onmicrosoft.com",
  [string] [Parameter(Mandatory=$true)] $usernameAAD = "admin@gt1101.onmicrosoft.com",
  [string] [Parameter(Mandatory=$true)] $passwordAAD = "ReverseParol44"
)

#region variables    
    $rdBrokerUrl = "rdbroker.wvd.microsoft.com"
    $dc = "advm"
    $location = "east us"    
    $subId = "5c14a947-e099-4b3f-932e-6e836da92be6"
    $adVnet = "adVNET"
    $adSubnet = "adSubnet"
#endregion

#region PS modules download
    # Download files required for this script from github ARMRunbookScripts/static folder
    $fileURI = "https://raw.githubusercontent.com/madsamuel/wvd/master"
    $FileName = "AzureModules.zip"
       
    Invoke-WebRequest -Uri "$fileURI/runbooks/$Filename" -OutFile "C:\$Filename"

    Expand-Archive "C:\AzureModules.zip" -DestinationPath 'C:\Modules\Global' -ErrorAction SilentlyContinue
    # ToBeDone # delete AzureModules.zip after unpack

    # Install required Az modules and AzureAD
    Import-Module Az.Accounts -Global
    Import-Module Az.Resources -Global
    Import-Module Az.Websites -Global
    Import-Module Az.Automation -Global
    Import-Module Az.Managedserviceidentity -Global
    Import-Module Az.Keyvault -Global
    Import-Module AzureAD -Global
    Import-Module Az.Network

    Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force -Confirm:$false
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -Confirm:$false
    Get-ExecutionPolicy -List
#endregion

#region check VNET domain controller 
    Write-Output "Prep DS credential."
    $securePasswordAAD = ConvertTo-SecureString $passwordAAD -AsPlainText -Force
    $pscredentialAAD = New-Object System.Management.Automation.PSCredential($usernameAAD, $securePasswordAAD)
    Write-Output "Ends DS credentials."   

    try {
        Connect-AzAccount -Credential $pscredentialAAD
    } catch {
        Throw "Could not connect!"
    }
    
    $SelectSub = Select-AzSubscription -SubscriptionId $subId
    $VNET = Get-AzVirtualNetwork -name $advnet
    ($VNET).AddressSpace.AddressPrefixes 
    Write-Output $("Found the VNET " + $VNET)   
   
    # subnet
    If (($VNET).Subnets.Name -eq $adSubnet) {
        Write-Output $("Found the subnet " + $adSubnet)  
    }
    else {
        Throw "Subnet not found!"
    }
    # end subnet
#endregion  

#region validate firewall
    
    Write-Output ('Veryfing firewall allows connection to WVD endpoint...')

    $var = test-netconnection "rdbroker.wvd.microsoft.com" -port 443
    
    if ($var.TcpTestSucceeded) {
        Write-Output "RD Broker is reachable."
    } else {
        Write-Output "RD Broker cannot be reached."   
        Throw
    }    

    Write-Output ('End veryfication.')
#endregion

#region validate domain firewall
    
    Write-Output ('Veryfing domain name connectivity...')

    $var = test-netconnection "gt1101.onmicrosoft.com" -port 53
    
    if ($var.TcpTestSucceeded) {
        Write-Output "Domain is reachable."
    } else {
        Write-Output "Domain cannot be reached."   
        Throw
    }    

    Write-Output ('End veryfication.')
#endregion