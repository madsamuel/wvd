<#
.SYNOPSIS
Generates a password credential object

.DESCRIPTION
Generate a new password (aka Client-Secret, Key) in the same way as you would do it manually in the Azure portal
- i.e. it is a Base64 GUID with a "=" character at the end

.EXAMPLE
$PasswordCredential = Get-PasswordCredential -ErrorAction Stop

Get a password credential object with all preset details
#>
function Get-PasswordCredential {

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param ()

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {
        $Guid = New-Guid
        $PasswordCredential = New-Object -TypeName Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential
        # this is the same end-date which gets created when you manually create a key with "never expires" in the Azure portal
        [datetime]$EndDate = "2299-12-31"
        [datetime]$StartDate = Get-Date
        $PasswordCredential.StartDate = $StartDate
        $PasswordCredential.EndDate = $EndDate
        $PasswordCredential.KeyId = $Guid
        $PasswordCredential.Password = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($Guid)))) + "="

        return $PasswordCredential
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}