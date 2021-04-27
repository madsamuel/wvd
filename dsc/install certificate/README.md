# Install non-CA certificates on set of VMs

This DSC installs a certificate in Trusted people. This is intended to be used in MSIX app attach when a non-CA certificate has been used to sign the MSIX application.
To learn more about MSIX app attach follow this [doc](https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach-azure-portal). This [doc](https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach#install-certificates) covers the manual process for installing the certificate. 

This template has 1 parameter:
- path, including file name, to the non-CA storage account 

Defaults:
- NA

This template performs the following actions:
- Downloads the certficate pointed as input
- Runs the DSC to install the cert to Trusted people
 
Click the button below to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fmadsamuel%2Fwvd%2Fmaster%2Fdsc%2Finstall%2520certificate%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>