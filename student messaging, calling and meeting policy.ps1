#This has been re-written to use the new AzureADPreview (version 2.0.2.102 at the time of writting)
#https://www.powershellgallery.com/packages/AzureADPreview

#Import the Azure Active Directory Module for Windows PowerShell cmdlets for Azure AD administrative tasks
Import-Module AzureADPreview

#We need to connect to Azure AD
Connect-AzureAD

#We need to import the SkypeOnlineConnector module
Import-Module SkypeOnlineConnector

#Skype is painful to work with, need to clobber on the import a lot of the time
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession -AllowClobber

#Let's put our policies into variables
$chat = "EduStudent - No Private Chat"
$call = "EduStudent - No Private Calling"
$meet = "EduStudent - No meeting"

#Also an after thought, we can do the same as above with the group name
$group = "All Cotlew Students"

#We need to get the GroupObjectId for the group which contains the member we want to apply the policies to.  Here we are finding "group name"
$groupid = Get-AzureADGroup -SearchString $group

#Now that we have the GroupObjectId we need the members from that group
$members = Get-AzureADGroupMember -ObjectId $groupid.objectid -All $true

#Now we have the members lets assign the chat policy to them, our policy is called $chat
foreach ($member in $members) {Grant-CsTeamsMessagingPolicy -PolicyName $chat -Identity $member.UserPrincipalName}

#Now we have the members lets assign the calling policy to them, our policy is called $call
foreach ($member in $members) {Grant-CsTeamsCallingPolicy -PolicyName $call -Identity $member.UserPrincipalName}

#Now we have the members lets assign the meeting policy to them, our policy is called $meet
foreach ($member in $members) {Grant-CsTeamsMeetingPolicy -PolicyName $meet -Identity $member.UserPrincipalName}