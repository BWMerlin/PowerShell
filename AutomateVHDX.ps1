#Script to install Hyper-V service, Install guest OS of Window 10, install OBS and VS Studio onto the guest OS

#Ask the user the following
#Where to save the covert-windowsimage.ps1
#Where to create the VHDX file
#Where the ISO is
#What version of Windows 10 they want
#where the unattend.xml is
#What admin username they want for the VM
#What admin password they want for the vm
#what name they want the Hyper-V guest to be called
#What name they want the guest OS to be called

$ISOPath = "C:\Users\Administrator\Downloads\SW_DVD9_Win_Pro_10_1909_64BIT_English_Pro_Ent_EDU_N_MLF_X22-17395.ISO"
#We need to know where the ISO we will be using it located so we will ask the user to give us the FULL path to the iso.
$ISOPath = Read-Host "Please type in the FULL path to the ISO that will be used"
#To get the editions available to be installed we need to mount the image first
$drivemount = Mount-DiskImage -ImagePath $ISOPath
#Now we have the ISO mounted we need to get the drive letter of the volume
$drive = Get-DiskImage -DevicePath $drivemount.DevicePath | Get-Volume
#Now we have the drive letter when need to get the list of indexs which contains the description of what editions are aviable to be installed
dism /get-wiminfo /wimfile:$($drive.DriveLetter):\sources\install.wim | Write-Host
#Now we can unount the drive
dismount-diskimage -imagepath $isopath
$WindowsEdition = Read-Host "Please type the Windows Edition you wish to install"
#"$env:userprofile\downloads\SW_DVD9_Win_Pro_10_1909_64BIT_English_Pro_Ent_EDU_N_MLF_X22-17395.ISO"
$VMName = Read-Host "Please enter a name for the virtual machine.  This will be used in both the Hyper-V console and the guest OS host name"
$Unattend = Read-Host "Please type the FULL path to the unattend.xml that will be used i.e. c:\unattend.xml"
$VMUsername = Read-Host "Please type the username you would like to for the VM guest"
$VMPassword = Read-Host "Please type in the password you would like for the VM guest" -AsSecureString
$VHDXPath = Read-Host "Please type the path where you would like the VHDX file to be saved to"
$VHDXSize = Read-Host "Please type the size in GB that you would like the VHDX to be i.e. 40GB"
$VMRAM = Read-Host "Please type in the size in GB how mcuh RAM you want the virtual machine to have i.e. 4GB"
$Downloadlocation = Read-Host "Please type in the location you would like to download to"

#We want to download Convert-WindowsImage from https://github.com/x0nn/Convert-WindowsImage/blob/master/Convert-WindowsImage.ps1 so that we can make a VHDX with an unattend from an ISO
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/x0nn/Convert-WindowsImage/master/Convert-WindowsImage.ps1" -OutFile $Downloadlocation\Convert-WindowsImage.ps1

#Let's download the unattend.xml file from


#We want to edit out unattend.xml, first we import it
$theunattend = [xml](Get-Content $unattendlocation)

$theunattend.unattend.settings.component.setupuilanguage[0].UILanguage="en-AU"
$theunattend.save("c:\myfile.xml")


#Next we create our VM, first we dotsource the script
. $Downloadlocation\Convert-WindowsImage.ps1

#Now we run the script
Convert-WindowsImage -SourcePath $ISOPath -VHDFormat VHDX -Edition $WindowsEdition -DiskLayout UEFI -VHDPath $VHDXPath\$VMName.vhdx -SizeBytes $VHDXSize -Unattend $Unattend -passthru

#Script to install Hyper-V service, Install guest OS of Window 10, install OBS and VS Studio onto the guest OS

#We will make the "assumption" that Hyper-V is not installed and use ifnot instead of if
if (-not ((Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All').State -eq 'Enabled'))
    {Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart}

#Check if Hyper-V Virtual Machine guest with the name of OBS exists
if (-not (get-vm -name "$VMName"))
        {New-VM -Name "$VMName" -MemoryStartupBytes $VMRAM -VHDPath $VHDXPath\$VMName.vhdx -Generation 2}

#Start the VM
Start-VM -Name $VMName

#Connect to the VM and install OBS (this is the demo line)
Invoke-Command -VMName $VMName -ScriptBlock {Get-Process PowerShell} -Credential (Get-Credential)

#We will make the "assumption" that OBS is not installed and use ifnot
Invoke-Command -VMName $VMName -ScriptBlock
    {if (-not (Get-Package -Name "OBS Studio"))
        {Invoke-WebRequest -Uri "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-24.0.3-Full-Installer-x64.exe" -OutFile $Downloadlocation\obs.exe} ; (Start-Process -FilePath $Downloadlocation\obs.exe /S)}


#Check to see if VS Studio is installed
Invoke-Command -VMName $VMName -ScriptBlock
    {if (-not (Get-Package -Name "Microsoft Visual Studio Code"))
        {Invoke-WebRequest -Uri "https://aka.ms/win32-x64-user-stable" -OutFile $Downloadlocation\visual.exe} ; (Start-Process -FilePath $Downloadlocation\visual.exe -Argument "/VERYSILENT /MERGETASKS=!runcode")}
