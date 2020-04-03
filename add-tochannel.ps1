#First we need to know where the people are who we want to add to the channel
$memberlist = "C:\4d.csv"

#then we import this list
$members = Import-Csv $memberlist

#We need to know the groupid to add the members to
$teamid = ""

#We need the csv of the channels
$channellist = "c:\channels.csv"

#We need the name of the channels to be created
$channelnames = Import-Csv $channellist

#We need to know the channel name to add the members to
#$channel = "4D"

#Now we add the users to the channel
foreach ($member in $members) {if $member.class eq  "4D" {Add-TeamChannelUser -groupid $teamid -user $memeber.email -displayname $channelnames -role member}}
