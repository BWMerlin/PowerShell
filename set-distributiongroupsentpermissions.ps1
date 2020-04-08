#We need the distinquished name of the OU that we want to change the groups in
$ou = "CN="

#We need the distribution group that will be added to dLMemSubmitPerms
$dg = "CN="

#Lets put all the shared mailboxes into an array to add them in one go
$thearray = @(
            
#shared mailbox1
"CN=shared mailbox1"

#shared mailbox2
"CN=shared mailbox2"

#shared mailbox3
"CN=shared mailbox3"

#shared mailbox4
"CN=shared mailbox4"

#shared mailbox5
"CN=shared mailbox5"
                )

#Lets search in the OU for the groups
$thelist = Get-ADObject -Filter 'ObjectClass -eq "group"' -SearchBase $ou

#Now lets add our shared mailboxes to authOrig and our distribution group to dLMemsSubmitPerms
#We will use -replace to do a bit of a cleanup and ensure consistency
foreach ($group in $thelist.DistinguishedName) {
    Set-ADObject $group -replace @{authOrig = $thearray}
    Set-ADObject $group -replace @{dLMemSubmitPerms = $dg}
    }
