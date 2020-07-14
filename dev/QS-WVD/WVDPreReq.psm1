[cmdletbinding()]
param(

)
Write-Verbose $PSScriptRoot

# Load central config file; Config File can be referenced within module scope by $script:CONFIG
Write-Verbose 'Load Config'
$script:CONFIG = Import-PowerShellDataFile -Path (Resolve-Path (Join-Path $PSScriptRoot 'ModuleConfig.psd1'))

Write-Verbose 'Import everything in sub folders public, private, classes folder'
$functionFolders = @('Public', 'Private', 'Classes')
ForEach ($folder in $functionFolders) {
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    If (Test-Path -Path $folderPath) {
        Write-Verbose -Message "Importing from $folder"
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1'
        ForEach ($function in $functions) {
            Write-Verbose -Message "  Importing $($function.BaseName)"
            try {
                . $($function.FullName)
            }
            catch {
                Write-Verbose ('Failed to import "{0}". Reason: "{1}"' -f $function.FullName, $_.Exception.Message)
            }
        }
    }
}
$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1').BaseName
Export-ModuleMember -Function $publicFunctions