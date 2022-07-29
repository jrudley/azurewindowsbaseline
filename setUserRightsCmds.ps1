

#Allow log on locally
.\SetUserRights -AddRight -UserRight SeInteractiveLogonRight -Username "Administrators" 
.\setUserRights -RemoveRight -UserRight SeInteractiveLogonRight -Username "Users"
.\setUserRights -RemoveRight -UserRight SeInteractiveLogonRight -Username "Backup Operators"

#Increase a process working set
.\SetUserRights -AddRight -UserRight SeIncreaseWorkingSetPrivilege -Username "Administrators" 
.\SetUserRights -AddRight -UserRight SeIncreaseWorkingSetPrivilege -Username "LocalService"
.\setUserRights -RemoveRight -UserRight SeIncreaseWorkingSetPrivilege -Username "Users"

#Enable computer and user accounts to be trusted for delegation
.\setUserRights -RemoveRight -UserRight SeEnableDelegationPrivilege -Username "Administrators" 

#Allow log on through Remote Desktop Services
.\SetUserRights -AddRight -UserRight SeRemoteInteractiveLogonRight -Username "Administrators" 
.\SetUserRights -AddRight -UserRight SeRemoteInteractiveLogonRight -Username "Remote Desktop Users" 
.\setUserRights -RemoveRight -UserRight SeRemoteInteractiveLogonRight -Username "Guests"


#Access this computer from the network
.\SetUserRights -AddRight -UserRight SeNetworkLogonRight -Username "Administrators"
.\SetUserRights -AddRight -UserRight SeNetworkLogonRight -Username "Authenticated Users"
.\setUserRights -RemoveRight -UserRight SeNetworkLogonRight -Username "Everyone"
.\setUserRights -RemoveRight -UserRight SeNetworkLogonRight -Username "Backup Operators"
.\setUserRights -RemoveRight -UserRight SeNetworkLogonRight -Username "Users"

#Bypass traverse checking
.\SetUserRights -AddRight -UserRight SeChangeNotifyPrivilege -Username "Administrators"
.\SetUserRights -AddRight -UserRight SeChangeNotifyPrivilege -Username "Authenticated Users"
.\SetUserRights -AddRight -UserRight SeChangeNotifyPrivilege -Username "Backup Operators"
.\SetUserRights -AddRight -UserRight SeChangeNotifyPrivilege -Username "LocalService"
.\SetUserRights -AddRight -UserRight SeChangeNotifyPrivilege -Username "NetworkService"
.\setUserRights -RemoveRight -UserRight SeChangeNotifyPrivilege -Username "Everyone"
.\setUserRights -RemoveRight -UserRight SeChangeNotifyPrivilege -Username "Users"


#Increase scheduling priority
.\setUserRights -RemoveRight -UserRight SeIncreaseBasePriorityPrivilege -Username "Window Manager\Window Manager Group"


#Shut down the system
.\setUserRights -RemoveRight -UserRight SeShutdownPrivilege -Username "Backup Operators"


#Deny log on through Remote Desktop Services cant get this to work. can remove, but not add
#.\SetUserRights -AddRight -UserRight SeDenyRemoteInteractiveLogonRight -Username "Guests"
#.\setUserRights -RemoveRight -UserRight SeDenyRemoteInteractiveLogonRight -Username "Guests"

$tempFolderPath = Join-Path $Env:Temp $(New-Guid)
New-Item -Type Directory -Path $tempFolderPath | Out-Null
secedit.exe /export /cfg $tempFolderPath\security-policy.inf


#get line number
$file = gci -literalpath "$tempFolderPath\security-policy.inf" -rec | % {
$line = Select-String -literalpath $_.fullname -pattern "Privilege Rights" | select -ExpandProperty LineNumber
}

#add string
$fileContent = Get-Content "$tempFolderPath\security-policy.inf"
$fileContent[$line-1] += "`nSeDenyRemoteInteractiveLogonRight = *S-1-5-32-546"
$fileContent | out-file "$tempFolderPath\security-policy.inf" -Encoding unicode

secedit.exe /configure /db c:\windows\security\local.sdb /cfg "$tempFolderPath\security-policy.inf"
rm -force "$tempFolderPath\security-policy.inf" -confirm:$false
