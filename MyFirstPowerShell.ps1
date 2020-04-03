if (Test-Path -LiteralPath "C:\Users\bwmer\Downloads\bob") {exit} else {New-Item -ItemType Directory -path "C:\Users\bwmer\Downloads" -Name "bob"}
if (Test-Path -LiteralPath "C:\Users\bwmer\Downloads\bob\myfile.txt") {exit} else {Copy-Item -LiteralPath "C:\Users\bwmer\Downloads\myfile.txt" -Destination "C:\Users\bwmer\Downloads\bob"}
notepad.exe

if ((Test-Path -LiteralPath "C:\Users\bwmer\Downloads\bob", "C:\Users\bwmer\Downloads\bob\myfile.txt") -notcontains $false) {Write-Host "both folder and file found"} else {Write-Host "The folder or file is missing"} 