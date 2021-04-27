param(
    [string]$certPath
)

## prepare temp folders
Write-Host "Prepare local folder!"

$workingFolder = "c:\temp"
$downloadDestination = Split-Path $certPath -leaf
$certLocalPath = $workingFolder + "\" + $downloadDestination

if ( !(Test-Path $workingFolder )) 
  {
      New-Item -Path $workingFolder -itemType directory -Force
  }
else 
  {
      Write-Host "Destination path exist!"
  }

## download certificate 
Write-Host "Download certificate start!" 

$sb = Start-Job -ScriptBlock {    
  Write-Host $args[0]
  Invoke-WebRequest -Uri $args[0] -OutFile $args[1]
} -ArgumentList $certPath, $certLocalPath

$null = Wait-Job $sb 

Write-Host "Download completed!"

## install certificate 
Write-Host "Installation completed"

Import-Certificate -CertStoreLocation cert:\LocalMachine\TrustedPeople -FilePath $certLocalPath

Write-Host "Installation completed"


