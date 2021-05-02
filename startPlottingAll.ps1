# Chia Plotting Automation Script 
# by Kostya
<#

    Examples:

      1. Start 3 plotting instances using drive D:\ as temp space and e:\ as destination with 40 min staggered start.
         This process will use folders D:\P0, D:\P1, D:\P2 as temp folders

        .\startPlottingAll.ps1 d:\ e:\ 3 40

      2. Start single plotting instances using drive D:\ as temp space and e:\ as destination immediately.
         This process will use folders D:\P0 as temp folders

        .\startPlottingAll.ps1 d:\ e:\

      3. Full named parameters:

        .\startPlottingAll.ps1 -tempPath d:\ -destinationPath e:\ -instanceCount 3 -delayMin 30

#>
param (
    [Parameter(Mandatory=$true)][string]$tempPath,
    [Parameter(Mandatory=$true)][string]$destinationPath,
	[int]$instanceCount = 1,
	[int]$delayMin = 0
)

for ($instanceNum = 0 ; $instanceNum -lt $instanceCount ; $instanceNum++){

	$instanceDelay = $instanceNum*$delayMin
	$arg = ".\startPlotting.ps1 -tempPath $($tempPath)P$($instanceNum)\ -destinationPath $destinationPath -delayMin $instanceDelay"
	"Starting process for Farmer $instanceNum..."
	Start-Process powershell -ArgumentList $arg -WindowStyle Minimized
}
"All Farmers started. Can close this window"