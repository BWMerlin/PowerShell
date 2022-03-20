#We need to install the Workspace ONE agent onto a remote system

#Organisation's Workspace ONE URL
$OrgWS1URL = ""

#Organisation's Workspace ONE location group ID
$OrgWS1ID = ""

#Organisation's staging user account
$OrgStageUser = ""

#Organisation's staging user password
$OrgStagePass = ""

#Where do we donwload the Workspace ONE agent from?
$WS1AgentDL = "https://packages.vmware.com/wsone/AirwatchAgent.msi"

<#Where do we want the file to download to?
Per VMware documentation https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/Windows_Desktop_Device_Management/GUID-uemWindeskDeviceEnrollment.html
the AirWatchAgent.msi file cannot be renamed
#>
$RemoteDLLocation = "C:\Program Files (x86)\AirwatchAgent.msi"

#First we need to ask what is the name of the remote computer to connect to.
$RemotePCName = Read-host -Prompt "Enter in the computer name to connect to"

#Now we connect to our remote computer
try {
    Enter-PSSession -ComputerName $RemotePCName
}
catch {
    Write-Host "Unable to connect to the remote computer"
}


#Now download the Workspace ONE agent onto the remote computer
Invoke-WebRequest -Uri $WS1AgentDL -OutFile $RemoteDLLocation

#Run the Workspace ONE agent on the remote computer
Start-Process msiexec.exe -Wait -ArgumentList "/I $RemoteDLLocation /quiet ENROLL=Y IMAGE=n SERVER=$OrgWS1URL LGName=$OrgWS1ID USERNAME=$OrgStageUser PASSWORD=$OrgStagePass ASSIGNTOLOGGEDINUSER=Y"

#Let's clean up after ourselves
Remove-Item $RemoteDLLocation

#Now can can close the remote connection
Exit-PSSession