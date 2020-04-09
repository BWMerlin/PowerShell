#We need to connect to Microsoft Online
Connect-MsolService

#We need to import the SkypeOnlineConnector module
Import-Module SkypeOnlineConnector

#Skype is painful to work with, need to clobber on the import a lot of the time
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession -AllowClobber

#Only thought of this after wards but we can put our policies into variables.  If you want to use these use $chat and $call instead of the "xxx Policy" etc
$chat = "Chat Policy"
$call = "Calling Policy"

#Also an after thought, we can do the same as above with the group name
$group = "group name"

#We need to get the GroupObjectId for the group which contains the member we want to apply the policies to.  Here we are finding "group name"
$groupid = Get-MsolGroup -all | Where-Object displayname -eq "group name"

#Now that we have the GroupObjectId we need the members from that group
$members = Get-MsolGroupMember -all -GroupObjectId $groupid.objectid

#Now we have the members lets assign the Chat policy to them, our Policy is called "Chat Policy"
foreach ($member in $members) {Grant-CsTeamsMessagingPolicy -PolicyName "Chat Policy" -Identity $member.EmailAddress}

#Note, you will probably need to reconnect to SkypeOnlineConnector again, Skype is a pain to work with.  Our policy is called "Calling Policy"
foreach ($member in $using:$members) {Grant-CsTeamsCallingPolicy -PolicyName "Calling Policy" -Identity $member.EmailAddress}

#Experimental stuff, untested but "should" work (comment out the above foreach if you want to use these)
#Start-Job -ScriptBlock {foreach ($member in $using:$members) {Grant-CsTeamsMessagingPolicy -PolicyName $chat -Identity $member.EmailAddress}}
#Start-Job -ScriptBlock {foreach ($member in $using:$members) {Grant-CsTeamsCallingPolicy -PolicyName $call -Identity $member.EmailAddress}}
