 # Chia Plotting Automation Script 
# by Kostya

<#

    Examples:

      1. Start using drive D:\P1\ as temp space and e:\ as destination with 40 min delay.
         This process will use folders D:\P1 as temp folders

        .\startPlotting.ps1 d:\P1\ e:\ 40

      2. Start single plotting using drived d:\P1\ as temp space and e:\ as destination immediately.

        .\startPlotting.ps1 d:\P1\ e:\ 0

      3. Full named parameters:

        .\startPlotting.ps1 -tempPath d:\ -destinationPath e:\ -delayMin 30

#>

param (
    [Parameter(Mandatory=$true)][string]$tempPath,
    [Parameter(Mandatory=$true)][string]$destinationPath,
	[int]$delayMin = 5
)

# Update Based on your System 
$chiaVersion = "1.1.5" # Update to the installed version of Chia.
$memBuffer = 4*1024 # Maximum memory commited per instance (change based on total memory and number of concurrent processes)
$numThreads = 2 # Number of threads per instance (recommended 2 to 4)
$delaySec = $delayMin * 60 # Delay between start of process.  This delays the plotting process
$logPath = ".\" # It will create a folder for the logs in this path (".\" means actual script folder location)
$logFolder = "Log" # Name of the Log folder
$pool = "..." # set your pool key here
$farmer = "..." # set your farmer key here
$numberOfPlotsPerInstance = 100 # This will give this number of plots per instance


# DO NOT CHANGE BELOW
$host.ui.RawUI.WindowTitle = "Chia Farmer: " + $tempPath + " Waiting " + $delayMin

$chiaDeamon = $env:LOCALAPPDATA + "\chia-blockchain\app-" + $chiaVersion + "\resources\app.asar.unpacked\daemon\chia.exe" 

# Check if the Log folder does exits or not and will create it if needed
$a = Test-Path $logFolder 
IF ($a -eq $false){
New-Item -Name $logFolder -ItemType "directory" -Path $logPath
Write-Host "The log folder has been created there: $logPath " # If the log folder do not exist it the Log folder will be created in the $logPath with this name $logFolder and the result will be shown to the user
}ELSE{
Write-Host "The Log folder has been located at : $logPath" # If the log folder does exist it will show to the user the actual path
}

$logFile = $logPath + $logFolder + "\" + $env:computername + "_" + $(Get-Date -Format "yyyy_MM_dd_HH_mm") + "_" + $delayMin + ".log"


Write-Output "Init Process to $tempPath Destination $destinationPath Memory $memBuffer threads $numThreads Delay $delayMin minutes" | Tee-Object -FilePath $logFile -Append

# Create directory if it does not exist
New-Item -ItemType Directory -Force -Path $tempPath

# If you are staggaring your plotting, you can use this
Start-Sleep -Seconds $delaySec


# Confirm it is working by outputing version
# &$chiaDeamon "version"

# Start plotting - Infinite Loop
for ($instanceCount = 0;;$instanceCount++)
{

  # Delete all temporary files, in case previous run did not complete
  Get-ChildItem -Path $tempPath -Include *.tmp -File -Recurse  | foreach { $_.Delete()}

  Write-Output "START Plotting $instanceCount to $tempPath Destination $destinationPath Memory $memBuffer threads $numThreads" | Tee-Object -FilePath $logFile -Append
  $logFile = $logPath + $logFolder + "\" + $env:computername + "_" + $(Get-Date -Format "yyyy_MM_dd_HH_mm_ss") + "_" + $instanceCount + ".log"
  $host.ui.RawUI.WindowTitle = "Chia Farmer: " + $tempPath + " plotting " + $instanceCount

  &$chiaDeamon  plots create -k 32 -n $numberOfPlotsPerInstance -f $farmer -p $pool -t $tempPath -d $destinationPath -b $memBuffer -r $numThreads | Out-File $logFile -Append
} 
