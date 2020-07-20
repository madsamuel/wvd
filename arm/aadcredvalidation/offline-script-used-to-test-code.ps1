#region credentials
$securePassword = ConvertTo-SecureString "10" -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential("ssa", $securePassword)

#Connect-AzureAD -Credential $pscredential
#endregion

try {
    $sess = New-PSSession -ComputerName "AdvM" -Credential $pscredential 

    $output = Invoke-command  -session $sess -scriptblock {
        [Net.ServicePointManager]::SecurityProtocol = "tls12"
        Install-Module AzureAD -Force
        Import-Module AzureAD -Force 

        Write-Output "Start script."    
        
        try {
            Connect-AzureAD -Credential $Using:pscredential -
            Write-Output "Authenticated."        
        }
        catch
        {
            Write-Output "Incorrect credentials."
        }

        try {
                Update-AzureADSignedInUserPassword -CurrentPassword $Using:securePassword -NewPassword $Using:securePassword 
                Write-Output "`n Password is correct."
            }
        catch {
            Write-Output "`nPassword is incorrect."
        }
    } 

    Disconnect-PSSession -session $sess 

    $Events = Select-String -InputObject $output -Pattern 'Password is correct'
    
    if ($Events -like "*Password is correct*") {
        # write to outpot obj
        Write-Output "Good"    
    } else {
        Write-Output "Bad"    
    }
}
catch {
    Write-Output "Bad"   
}