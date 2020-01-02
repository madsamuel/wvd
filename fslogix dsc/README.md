# Install FSLogix agent on set of VMs

This template adds FSLogix agent to a set of virtual machines, part of a WVD host pools. This host pool needs to be alrady created.
To create a host pool follow this [doc](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-powershell).

This template has 1 parameters:
- Path to SMB storage path where profiles will be stored

Defaults:
- Profile disk type defaults to VHD
- Profiles apply for everyone
- Default size is 30 GB per profile

This template performs the following actions:
- Downloads FSLogix agents
- Install FSLogix agents
- Performs a simple verification of the installation
 
This template DOES NOT:
- Configure the network storage
- Set ACLs on the network path 
- Implements best practices for performance or cost.

Information on the above is available in the WVD documentation here [article](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-user-profile).
Click the button below to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2FAzure%2FRDS-Templates%2Fmbastos%2Fjoinhostpool%2Fwvd-sh%2Fjoinhostpool%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
