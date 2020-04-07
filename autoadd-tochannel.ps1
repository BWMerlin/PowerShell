#Where is the file?
$fielocation = "C:\Users\Administrator\Downloads\classtoimport.csv"

#Import the file into powershell and pipe it to group-object and group them into the time tabled class
$studentandclasslist = Import-Csv $fielocation | Group-Object -Property class

#Can we write host the class names?
Write-Host $studentandclasslist.name

#Lets try making a channel, channels must be private to be able to add members to them)
foreach ($line in $studentandclasslist.name) {New-TeamChannel -GroupId <id> -DisplayName $line -MembershipType Private}


#Now lets add students into the correct channel based of their group
Add-TeamChannelUser -GroupId <id> -DisplayName "<>" -User email@address.com

#Can we do something with the .group of $studentandclasslist (note this write all of them to host)
foreach ($student in $studentandclasslist.group) {Write-Host $student}
