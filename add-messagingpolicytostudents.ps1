Connect-MsolService
Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession -AllowClobber

$groupid = Get-MsolGroup -all | Where-Object displayname -eq ""
$members = Get-MsolGroupMember -all -GroupObjectId $groupid.objectid

foreach ($member in $members) {Grant-CsTeamsMessagingPolicy -PolicyName "EduStudent - No Private Chat" -Identity $member.EmailAddress}
foreach ($member in $members) {Grant-CsTeamsCallingPolicy -PolicyName "EduStudent - No Private Calling" -Identity $member.EmailAddress}
