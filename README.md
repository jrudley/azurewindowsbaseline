# azurewindowsbaseline

Import required dsc modules:
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name AuditPolicyDsc -Force
        Install-Module -Name SecurityPolicyDsc -Force
        Install-Module -Name NetworkingDsc -Force
        
Generate the MOF:    .\AzureBaselineDscWindows2019.ps1
Execute DSC: Start-DscConfiguration -Path .\AzureBaselineDscWindows2019  -Force -Verbose -Wait        

Copy setUserRights.ps1 to a temp folder and run setUserRightsCmds.ps1

Reboot Azure VM and the guest assignment will re-evaluate showing 100% passing compliance.
