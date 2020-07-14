<#
.SYNOPSIS
Create the function to create the authorization signature

.DESCRIPTION
Create the function to create the authorization signature

.EXAMPLE
An example

#>
function New-AutoAccountSignature {

    param(
        [Parameter(mandatory = $true)]
        [string] $customerId,
        
        [Parameter(mandatory = $true)]
        [string] $sharedKey,
        
        [Parameter(mandatory = $true)]
        [string] $date,
        
        [Parameter(mandatory = $true)]
        [string] $contentLength,
        
        [Parameter(mandatory = $true)]
        [string] $method,
        
        [Parameter(mandatory = $true)]
        [string] $contentType,

        [Parameter(mandatory = $true)]
        [string] $resource
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }
    
    process {
        $xHeaders = "x-ms-date:" + $date
        $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

        $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
        $keyBytes = [Convert]::FromBase64String($sharedKey)

        $sha256 = New-Object System.Security.Cryptography.HMACSHA256
        $sha256.Key = $keyBytes
        $calculatedHash = $sha256.ComputeHash($bytesToHash)
        $encodedHash = [Convert]::ToBase64String($calculatedHash)
        $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
        
        return $authorization
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}