<#
We want an easy way to manage devices by adding, assigning and removed them from Workspace ONE, Active Directory, printing lists and barcodes and so on
Built using the Workspace ONE API tutorial from https://www.brookspeppin.com/2021/07/24/rest-api-in-workspace-one-uem/ and the 
PowerShell GUI tutorial from https://theitbros.com/powershell-gui-for-scripts/
#>

#Let's set some variables
#Which Active Directory server do we want to search for our users in?
$DC = ""
#Which OU do we want to search for our users in?
$OU = ""
#What is your Workspace ONE LocationGroupID number?
$LocationGroupIdNumber = ""
#What device ownership type do you want?
$OwnershipType = "C"
#What device platform type do you want?
$PlatformIdType = "12"

#We need some details on how to connect to Workspace ONE via API

#First we set up our OAuth details I know API keys shouldn't be stored in code but not sure how else todo this for now
$Server = "https://cn500.airwatchportals.com"
$client_id = ""
$client_secret = ""

#Now we need out access token which is found here https://kb.vmware.com/s/article/76967
#URI end points can be found here https://as500.airwatchportals.com/api/help

$access_token_url = "https://apac.uemauth.vmwservices.com/connect/token"

#Our REST API body
$body = @{
    grant_type    = "client_credentials"
    client_id     = $client_id
    client_secret = $client_secret
}

#Now we get our OAuth token
try {
    $response = Invoke-WebRequest -Method Post -Uri $access_token_url -Body $body -UseBasicParsing
    $response = $response | ConvertFrom-Json
    $oauth_token = [string]$($response.access_token)

} catch {
    $ErrorMessage = $PSItem | ConvertFrom-Json
    Write-Log "Failed to create OAuth Token for: $env with following ErrorCode: $($ErrorMessage.errorCode) - $($ErrorMessage.message)" -ForegroundColor Red
}

#Our headers which we will need to send
$header_v1 = @{
    "Authorization" = "Bearer " + $oauth_Token;
    "Accept" = "application/json;version=1";
    "Content-Type" = "application/json"
}

#We need .NET to make our GUI so let's load that up for PowerShell
Add-Type -assembly System.Windows.Forms

#Let's create the actual GUI window
$main_form = New-Object System.Windows.Forms.Form

#Let's label our GUI window
$main_form.Text = "PS WS1"

#Our GUI needs some dimensions
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true

#A label that says "Select a user ID number"
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select a user ID number"
$Label.Location  = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

#A combo box which will contain a list of users from AD
$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 200
#We want to search the our domain but only in the specified OU but we want to search by "sID" number so we can barcode scan them in
$Users = Get-ADUser -filter * -Properties extensionAttribute6 -SearchBase $OU -Server $DC

Foreach ($User in $Users)
{
#$ComboBox.Items.Add($User.SamAccountName);
$ComboBox.Items.Add($User.extensionAttribute6);
}
#Where do we want our $ComboBox to actually be placed in our GUI
$ComboBox.Location  = New-Object System.Drawing.Point(200,10)
$main_form.Controls.Add($ComboBox)

#We want a text input that allows us to input the serial number of a device
$DeviceSerialNumberInput = New-Object System.Windows.Forms.TextBox
#Where do we want our $DeviceSerialNumberInput TextBox to be placed in our GUI
$DeviceSerialNumberInput.Location = New-Object System.Drawing.Point(200,130)
$main_form.Controls.Add($DeviceSerialNumberInput)

#A label that states "Users AD login name"
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Users AD login name"
$Label2.Location  = New-Object System.Drawing.Point(0,40)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)

#The resuts that actuall show the Users AD login name
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = ""
$Label3.Location  = New-Object System.Drawing.Point(200,40)
$Label3.AutoSize = $true
$main_form.Controls.Add($Label3)

#A label that states "Users device in Workspace ONE:
$Label4 = New-Object System.Windows.Forms.Label
$Label4.Text = "Users device in Workspace ONE"
$Label4.Location  = New-Object System.Drawing.Point(0,70)
$Label4.AutoSize = $true
$main_form.Controls.Add($Label4)

#The results returned showing the users device from Workspace ONE
$Label5 = New-Object System.Windows.Forms.Label
$Label5.Text = ""
$Label5.Location  = New-Object System.Drawing.Point(200,70)
$Label5.AutoSize = $true
$main_form.Controls.Add($Label5)

#A label that states "The users Workspace ONE ID"
$Label6 = New-Object System.Windows.Forms.Label
$Label6.Text = "The users Workspace ONE ID"
$Label6.Location  = New-Object System.Drawing.Point(0,100)
$Label6.AutoSize = $true
$main_form.Controls.Add($Label6)

#The actual results for the "Workspace ONE ID of the user"
$Label7 = New-Object System.Windows.Forms.Label
$Label7.Text = ""
$Label7.Location  = New-Object System.Drawing.Point(200,100)
$Label7.AutoSize = $true
$main_form.Controls.Add($Label7)

#A label that says "Scan device serial number"
$Label8 = New-Object System.Windows.Forms.Label
$Label8.Text = "Scan device serial number"
$Label8.Location  = New-Object System.Drawing.Point(0,130)
$Label8.AutoSize = $true
$main_form.Controls.Add($Label8)

#Let's have a button that people can push #PushItPushItRealGood
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(400,10)
$Button.Size = New-Object System.Drawing.Size(150,23)
$Button.Text = "Check Active Directory"
$main_form.Controls.Add($Button)

#We are going to make a second button to check Workspace ONE but really we don't need one as we could use the first but let's try
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Size(400,70)
$Button2.Size = New-Object System.Drawing.Size(150,23)
$Button2.Text = "Check users device in Workspace ONE"
$main_form.Controls.Add($Button2)

#We want to make a button to allow us to check what the users Workspace ONE id number is
$Button3 = New-Object System.Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Size(400,100)
$Button3.Size = New-Object System.Drawing.Size(150,23)
$Button3.Text = "Check users Workspace ONE ID"
$main_form.Controls.Add($Button3)

#Now let's give users a button that they can click on to assing a device to a user in Workspace ONE
$Button4 = New-Object System.Windows.Forms.Button
$Button4.Location = New-Object System.Drawing.Size(400,130)
$Button4.Size = New-Object System.Drawing.Size(150,23)
$Button4.Text = "Assign device to user"
$main_form.Controls.Add($Button4)

#What code do we want to actually run when people "Salt and Peper" our button
$Button.Add_Click(
{
#We still want our AD user but maybe we can put this into a variable and have the lable call that so we can use .SamAccountName
$GetUser = Get-ADUser -Server $DC -Filter "extensionAttribute6 -eq '$($ComboBox.selectedItem)'"
$Label3.Text = $GetUser.SamAccountName
}
)

#Let us check Workspace ONE for the users device
$Button2.Add_Click(
{
$UserToCheck = $Label3.Text 
$device = Invoke-RestMethod -Uri "$Server/api/mdm/devices/search?user=$UserToCheck" -Method Get -Headers $header_v1
$Label5.Text = $device.Devices.SerialNumber
}
)

#Let us check Workspace ONE for the users ID number
$Button3.Add_Click(
{
$UserToCheck = $Label3.Text 
$UserIDCheck = Invoke-RestMethod -Uri "$Server/API/system/users/search?username=$UserToCheck" -Method Get -Headers $header_v1
$Label7.Text = $UserIDCheck.Users.id.Value
}
)

<#We need to know the folowing
WorkSpace ONE user ID for our user who we are going to assign the deivce to
LocationGroupId for the user and device
Device FriendlyName i.e. OrgCode-%SerialNumber%
Device SerialNumber i.e. 
Ownership
Based on trail and error (because I couldn't find it explicted stated in the WS1 API documentation)

LocationGroupId = "" (Unsure where you can find this in the console)
Ownership "C" = Corporate - Dedicated 
Ownership "E" =  Employee Owned?
PlatformId "5" = Android
PlatformId "6" = Athena
PlatformId "9" = Windows 7
PlatformId "10" = Apple macOS
PlatformId "11" = Windows Phone
PlatformId "12" = Windows Desktop
#>

$DeviceBody = @{
    LocationGroupId = $LocationGroupIdNumber
    FriendlyName = $DeviceSerialNumberInput.Text
    Ownership = $OwnershipType
    PlatformId = $PlatformIdType
    SerialNumber = $DeviceSerialNumberInput.Text

}

#Assign that actual device to a user in Workspace ONE

<# This code may have changed
$Button4.Add_Click(
{
$UserToCheck = $Label3.Text 
$deviceenrollment = Invoke-RestMethod -Uri "$Server/API/system/users/$userid/registerdevice" -Method Post -Headers $header_v1 -Body ($body | ConvertTo-Json)
}
)
#>

#Ths is possible the new correct code
$Button4.Add_Click(
{
$UserID = $Label7.Text 
$DeviceEnrollment = Invoke-RestMethod -Uri "$Server/API/system/users/$UserID/registerdevice" -Method Post -Headers $header_v1 -Body ($DeviceBody | ConvertTo-Json)
}
)

#Let's show everyone the GUI
$main_form.ShowDialog()