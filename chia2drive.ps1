# Chia Plotting Automation Script 
# by Kostya

<#
    Simple robocopy command to move files from source to destination in a continious process
    Modify as follows:

    .\chia2drive.ps1 d:\ f:\ c:\scripts\filelog.log

#>


param (
    [Parameter(Mandatory=$true)][string]$tempPath,
    [Parameter(Mandatory=$true)][string]$plotPath,
	[string]$log = "c:\log\chia2drive.log"
)


robocopy $tempPath $plotPath *.plot /J /MOV /MOT:15 /LOG+:$log /TEE