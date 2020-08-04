# azure runbook using Test-NetConnection to validate if WVD endpoints are accessible
# part of validation the input parameters for WVD quick start
$var = test-netconnection rdbroker.wvdselfhost.microsoft.com -port 443
if ($var.TcpTestSucceeded) {
    Write-Output "Resolvable"
} else {
    Write-Output "Firewall"   
}