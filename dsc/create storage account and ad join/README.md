# Create storage account 

# Join storage account to DC
MUST BE UPDATED

Subscription where the storage account is created. 

Resourge group with layer 3 connectivity to the domain controller.

Domain contorller name is the host name of the VM/physical server acting as domain controller.

Domain name where the storage account computer object is going to be created.

Storage account resource group is the resource group where the storage account was created in. 

Storage account is hte name of the storage account. 

Admin user name is the UPN for an account with global admin permission on Auzre AD.    

Information on the above is available in the WVD documentation here [article](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-user-profile).
Click the button below to deploy:


Click the button to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fmadsamuel%2Fwvd%2Fmaster%2Fcreate%20storage%20account%20and%20ad%20join%2Fdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
