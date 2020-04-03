#We need to know the location and name of our csv file
$csvlocation = Read-Host "Type the FULL path to the location of the .csv file i.e c:\file.csv"
 
 #We need an array that contains our students
$listofstudents = Import-Csv $csvlocation
 
#What team are we adding students to?
$theteam = Read-Host "Enter the hash ID of the team you want to add students to"
 
#connect to Teams
#Connect-MicrosoftTeams
 
#Add students to the team
#The rows will be assigned the variable $student.  We want a column heading called email.  We will select the email address from each row with $student.email and then feed that into add-team
foreach ($student in $listofstudents) {Add-TeamUser -GroupId $theteam -User $student.email -Role Member}
