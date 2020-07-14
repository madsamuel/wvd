@{
    # General Information #
    # =================== #
    # Environment
    subscriptionId                        = "[subscriptionId]"      # user input
    tenantId                              = "[tenantId]"      # AD tenant
    objectId                              = "[objectId]"      # from serviceprincipal
    
    # Pipeline
    WVDDeploymentServicePrincipal         = "WVDServiceConnection"              # default
  
    # ResourceGroups
    location                              = "eastus"                            # user input
    resourceGroupName                     = "[resourceGroupName]"                         # default
    wvdMgmtResourceGroupName              = "QS-WVD-MGMT-RG"                    # default
    #######################

    # Key Vault related #
    # ================= #  
    keyVaultName                          = "[keyVaultName]"               # default
    #####################
    
    # Storage related #
    # =============== #
    wvdAssetsStorage                      = "[assetsName]"             # generated with date & time to ensure uniqueness
    profilesStorageAccountName            = "[profilesName]"           # generated with date & time to ensure uniqueness
    storageAccountSku                     = "Standard_LRS"                      # default
    storageAccountAuthentication          = "AD"                                # default for now, could become user input
    profilesShareName                     = "wvdprofiles"                       # default
    ###################

    # Host pool related #
    # ================== #
    hostpoolName                          = "QS-WVD-HP"                         # default
    hostpoolType                          = "Pooled"                            # default
    maxSessionLimit                       = 16                                  # default
    loadBalancerType                      = "BreadthFirst"                      # default
    vmNamePrefix                          = "QS-WVD-VM"                         # default
    vmSize                                = "Standard_D2s_v3"                   # default
    vmNumberOfInstances                   = 2                                   # default
    vmInitialNumber                       = 1                                   # default
    diskSizeGB                            = 128                                 # default
    vmDiskType                            = "Premium_LRS"                       # default
    domainJoinUser                        = "[tenantAdminDomainJoinUPN]"        # user input
    domainName                            = "[existingDomainName]"            # taken from domainJoinUser
    adminUsername                         = "[existingDomainUsername]"          # taken from domainJoinUser
    AdminPasswordSecret                   = "adminPassword"                      # user input
    computerName                          = "[computerName]"
    vnetName                              = "[existingVnetName]"                            # search for existing vnet
    vnetResourceGroupName                 = "[virtualNetworkResourceGroupName]"                                # search for existing vnet resource group
    subnetName                            = "[existingSubnetName]"                          # search for existing subnet in existing vnet
    enablePersistentDesktop               = $false                              # default
    ######################

    # App group related #
    # ================== #
    appGroupName                          = "QS-WVD-RAG"                        # default
    DesktopAppGroupName                   = "QS-WVD-DAG"                        # default
    targetGroup                           = "[targetGroup]"
    principalIds                          = "[principalIds]"  # principal ID of test user group
    testUsername                          = "WVDTestUser003"                    # default
    testPassword                          = "Quickstart123!"                    # default
    workSpaceName                         = "QS-WVD-WS"                         # default
    workspaceFriendlyName                 = "WVD Workspace"                     # default
    ######################

    # Imaging related #
    # ================ #
    imagingResourceGroupName              = "QS-WVD-IMG-RG"                     # default
    imageTemplateName                     = "QS-WVD-ImageTemplate"              # default
    imagingMSItt                          = "[imagingMSItt]"                    # UNSURE
    sigGalleryName                        = "[sigGalleryName]"                  # UNSURE
    sigImageDefinitionId                  = "<sigImageDefinitionId>"            # supposedly filled in by pipeline
    imageDefinitionName                   = "W10-20H1-O365"                     # default
    osType                                = "Windows"                           # default
    publisher                             = "MicrosoftWindowsDesktop"           # default
    offer                                 = "office-365"                        # default
    sku                                   = "20h1-evd-0365"                     # default
    imageVersion                          = "latest"                            # default
    ######################


    # Authentication related
    # ==================== #
    identityApproach                      = "AD" # (AD or AADDS)                # default for now, could become user input
    
    # Only required for AD
    ADWVDSecretsGroupName                 = "WVDSecrets"                        # default
    
    # Only required for AADDS
    # domainJoinPrincipalName               = "domainJoinUser@cedward.onmicrosoft.com"
    ########################
}
