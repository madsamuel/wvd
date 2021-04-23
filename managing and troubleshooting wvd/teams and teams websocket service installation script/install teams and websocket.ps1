# This script is written to act as a sample on how Teams and its optimization can be installed on a Windows 10 machine
# This script assume x64 OS and run as admin (aka elevated permissions)
# create registry entry
###################################

Write-Host "Image preparation started!"

Push-Location
Set-Location HKLM:
if ( !(Test-Path .\Software\Microsoft\Teams\) ) 
    {
        New-Item -Path .\software\Microsoft\Teams 

        New-ItemProperty -Path .\software\Microsoft\Teams -Name "IsWVDEnvironment" -Value "1"  -PropertyType "DWORD" -Force
    }
    else
    {
        Write-Host "Destination path exist!"
    }    
Pop-Location

Write-Host "Image preparation completed!"

###################################
# install WebSocket
###################################

## prepare temp folders
Write-Host "Prepare local folder!"

$workingFolder = "c:\temp"

if ( !(Test-Path $workingFolder )) 
    {
        New-Item -Path $workingFolder -itemType directory -Force
    }
else 
    {
        Write-Host "Destination path exist!"
    }

## download WebSocket msi
Write-Host "Teams WebSocket Service start download!" 

$teamWebSocketMSI = "MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi"
$downloadDestination = $workingFolder + "\" + $teamWebSocketMSI

$sb = Start-Job -ScriptBlock{    
    Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile "c:\temp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi"  
}
$null = Wait-Job $sb 

Write-Host "Teams WebSocket Service downloaded!"

## install WebSocket service
Write-Host "Start WebSocket install!"

$installPath = $workingFolder + "\" + $teamWebSocketMSI
Start-Process $installPath -ArgumentList "/quiet" -Wait 

Write-Host "Complete WebSocket completed!"

###################################
#download and install teams 
###################################

Write-Host "Start Teams download!"

$teamsMSI = "Teams.msi"
$downloadDestination = $workingFolder + "\" + $teamsMSI
$logsDestination = $workingFolder + "\Teams.logs"

$sb = Start-Job -ScriptBlock{    
    Invoke-WebRequest -Uri "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true" -OutFile "c:\temp\Teams.msi"
}
$null = Wait-Job $sb 

Write-Host "Complete Teams download!"

###################################
# install teams
###################################

Write-Host "Teams install start!"

Start-Process -FilePath 'msiexec.exe' -Argument "/i $downloadDestination /l*v $logsDestination ALLUSER=1" -Wait

Write-Host "Team install completed!"
