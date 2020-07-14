<#
.SYNOPSIS
Create the function to create and post the request

.DESCRIPTION
Create the function to create and post the request

.PARAMETER customerId
Parameter description

.PARAMETER sharedKey
Parameter description

.PARAMETER body
Parameter description

.PARAMETER logType
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Send-LogAnalyticsData {

    param(
        [Parameter(mandatory = $true)]
        [string] $customerId,
        
        [Parameter(mandatory = $true)]
        [string] $sharedKey,
        
        [Parameter(mandatory = $true)]
        [string] $body,
        
        [Parameter(mandatory = $true)]
        [string] $logType
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)    
        
        . "$PSScriptRoot\New-AutoAccountSignature.ps1"
    }

    process {
        $method = "POST"
        $contentType = "application/json"
        $resource = "/api/logs"
        $rfc1123date = [datetime]::UtcNow.ToString("r")
        $contentLength = $body.Length

        $signaturInputObject = @{
            customerId    = $customerId 
            sharedKey     = $sharedKey 
            Date          = $rfc1123date 
            contentLength = $contentLength 
            FileName      = $fileName 
            Method        = $method 
            ContentType   = $contentType 
            resource      = $resource
        }
        $signature = New-AutoAccountSignature @signaturInputObject
        $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

        $headers = @{
            "Authorization"        = $signature;
            "Log-Type"             = $logType;
            "x-ms-date"            = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }

        $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
        return $response.StatusCode
    }
    
    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}