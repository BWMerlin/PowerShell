#We need to know the location and name of our csv file
#$csvlocation = Read-Host "Type the FULL path to the location of the .csv file i.e c:\file.csv"
$csvlocation = "C:\specialists.csv"

#We need an array that contains our students
$listofstaff = Import-Csv $csvlocation

#What team are we adding students to?
#$theteam = Read-Host "Enter the hash ID of the team you want to add students to"
$theteam = ""

#connect to Teams
#Connect-MicrosoftTeams

#Add students to the team
#The rows will be assigned the variable $staff.  There are three headings and we want the heading email.  We will select the email address from each row with $staff.email and then feed that into add-team
foreach ($staff in $listofstaff) {Add-TeamUser -GroupId $theteam -User $staff.email -Role Owner}
