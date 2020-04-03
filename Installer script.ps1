#Script to install Hyper-V service, Install guest OS of Window 10, install OBS and VS Studio onto the guest OS

#We will make the "assumption" that Hyper-V is not installed and use ifnot instead of if
if (-not ((Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All').State -eq 'Enabled')
    {Enable-WindowsOptionalFeature -online -FeatureName "Microsoft-Hyper-V-All" -NoRestart}

#Check if Hyper-V Virtual Machine guest with the name of OBS exists
$VMName="OBS"
if (-not (get-vm -name "$VMName"))
        {New-VM -Name "$VMName" -MemoryStartupBytes 4GB -NewVHDPath \$VMName.vhdx -NewVHDSizeBytes 40GB -Generation 2 -BootDevice CD }
#Install guest OS of Windows 10

#When need to connect to "OBS" remotely to enable us to run remote commands
Enter-PSSession -VMName $VMName -Credential (Get-Credential)

#To be able to run remote commands we need to add the remote host "OBS" to our local TustedHosts list
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $VMName

#Should only need the invoke-command to install application on guest VM
Invoke-Command -VMName $VMName -ScriptBlock {Get-Process PowerShell} -Credential (Get-Credential)

#We will make the "assumption" that OBS is not installed and use ifnot
if (-not (Get-Package -Name "OBS Studio"))
    {Invoke-WebRequest -Uri "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-24.0.3-Full-Installer-x64.exe" -OutFile $env:TEMP\obs.exe} ; (Start-Process -FilePath $env:TEMP\obs.exe /S)


#Check to see if VS Studio is installed
if (-not (Get-Package -Name "Microsoft Visual Studio Code"))
    {Invoke-WebRequest -Uri "https://aka.ms/win32-x64-user-stable" -OutFile $env:TEMP\visual.exe} ; (Start-Process -FilePath $env:TEMP\visual.exe -Argument "/VERYSILENT /MERGETASKS=!runcode")
