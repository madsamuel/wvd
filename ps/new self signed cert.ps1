New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "WVDcontoso.com" -FriendlyName "MSIX app attach" -NotAfter (Get-Date).AddYears(1)

New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "WVDcontoso.com" -FriendlyName "MSIX app attach" -NotAfter (Get-Date).AddYears(10)

New-SelfSignedCertificate -Type Custom -Subject "CN=WVDContosoAppAttach" -KeyUsage DigitalSignature -FriendlyName "WVDContosoAppATtach" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")