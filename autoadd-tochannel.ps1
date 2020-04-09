#Where is the file?  It needs the headers (in order) student,class
$fielocation = ""

#Import the file into powershell and pipe it to group-object and group them into the time tabled class
$studentandclasslist = Import-Csv $fielocation | Group-Object -Property class

#We need to know the groupid of the team
$teamid = ""

#Lets try making a channel, channels must be private to be able to add members to them)
foreach ($line in $studentandclasslist.name) {New-TeamChannel -GroupId $teamid -DisplayName $line -MembershipType Private}

#Now that we have the channels must add the students into the team first
foreach ($student in $studentandclasslist.group) {Add-TeamUser -GroupId $teamid -User $student.student -Role Member}

#Now we add students into the channels they are suppose to belong to
$classes = $studentandclasslist.name# Processes based on each class
foreach($xclass in $classes){    #Instantiates the variable with null value
    $null = $classusers,$channel    #Sorts users based on the Class, in this casse will be the first class($xclass) in $Classes 
    $classusers = $studentandclasslist.group | Where-Object Class -eq $xclass
    $channel = Get-TeamChannel -GroupId $teamid
        foreach ($user in $classusers){
        Add-TeamChannelUser -GroupId $teamid -DisplayName $xclass -User $user.student
    }}
