# Join virtual machine to an Windows Virtual Desktop host pool

This template adds set of virtual machines running Windows 7 to a WVD host pools. To create a host pool follow this [doc](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-powershell).

The Windows 7 image must have the latest updates, both mandatory and optional. Installing those makes sure that Remote Desktop Protocol 8.0 update (KB2592687) is installed. 

Once the update is installed open the Local Group Policy Editor and navigate to Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Remote Session Environment. 

For end users to be able to successfully connect VMs must be domain joined. This can be done via this [doc](https://azure.microsoft.com/en-us/resources/templates/201-vm-domain-join-existing/).

This template has 3 parameters:

- Resrouce Group
- Registration Token
- Vm Name

There is a forth parameter but you should ignore it. It is just a timestamp for the custom script extension used by this template.

The template performs the following actions:
- Validate pressence of KB25952687 
- Download the Windows Virtual Desktop Agent for Windows 7 
- Install the Windows Virtual Desktop Agent for Windows 7
- Download the Windows Virtual Desktop Agent Manager for Windows 7 
- Install the Windows Virtual Desktop Agent Manager for Windows 7
- Performs a simple verification of the installation
 
To deploy the template you need the registration token of the host pool you want to add the virtual machine.

To obtain the registration token, you need the *Windows Virtual Desktop Cmdlets for Windows PowerShell*.
This [article](https://docs.microsoft.com/en-us/powershell/windows-virtual-desktop/overview) has the instrunction on how to download and import the modulre.

Once you have imported the *Windows Virtual Desktop Cmdlets for Windows PowerShell*, you need to sign in to WVD.

```powershell
Add-RdsAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com
```

Now, you generate a registration token that is used to join virtual machiens to the wvd host pool:
```powershell
New-RdsRegistrationInfo -TenantName <tenantname> -HostPoolName <hostpoolname> -ExpirationHours <number of hours>
```

You can obtain th token by running the follwong command:
```powershell
(Export-RdsRegistrationInfo -TenantName <tenantname> -HostPoolName <hostpoolname>).Token
```




Click the button below to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fmadsamuel%2Fwvd%2Fmaster%2Fdsc%2Fwin%25207%2520agent%2520deployment%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
