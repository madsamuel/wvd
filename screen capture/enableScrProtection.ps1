#Enable screen protection 
write-host "Start enable screen protection..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableScreenCaptureProtection /t REG_DWORD /d 1

write-host "End enable screen protection"


