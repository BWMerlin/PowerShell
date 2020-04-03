#lets create a team

#We need the name of the team
#$teamname = Read-Host "Please type the synergetic code i.e. 09DRA4 of the class you want to create a team for"
$teamname = "Prep"

#We need a csv of the teachers
$teachers = "c:\teachers.csv"

#We need to know who will be the team owners
$teamowners = Import-Csv $teachers

#We need to a csv of the leadership
$leadership = "c:\leadership.csv"

#We need to know who will be leadership team owners
$leadershipowners = Import-Csv $leadership

#We need a csv of the specialists
$specialists = "c:\specialists.csv"

#We need to know who will be specialists owners
$specialistsowners = Import-Csv $specialists

#We need the csv of the channels
$channellist = "c:\channels.csv"

#We need the name of the channels to be created
$channelnames = Import-Csv $channellist

#We need the list of students to be added to the team
$students = "C:\students.csv"

#We need to know who the team members will be
$teammembers = Import-Csv $students

#Now we make the team
$theteam = New-Team -DisplayName $teamname -Description $teamname -template EDU_Class

#Add the channels from $channelnames
foreach ($channel in $channelnames) {New-TeamChannel -GroupId $theteam.groupid -DisplayName $channel.class}

#Add the leadership from $leadershipowners
foreach ($leader in $leadershipowners) {Add-TeamUser -GroupId $theteam.groupid -User $leader.email -Role Owner}

#Add the teachers from $teamowners
foreach ($owner in $teamowners) {Add-TeamUser -GroupId $theteam.GroupId -User $owner.email -Role Owner}

#Add the specialists from $specialistsowners
foreach ($special in $specialistsowners {Add-TeamUser -GroupId $theteam.GroupId -User $special.email -Role Owner}

#Add the students from $teammembers
foreach ($member in $teammembers) {Add-TeamUser -GroupId $theteam.groupid -User $member.email -Role Member}
