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
	[int]$delayMin = 0 #default to no delay
)

# Update Based on your System 
$chiaVersion = "1.1.5" # Update to the installed version of Chia.
$memBuffer = 4*1024 # Maximum memory commited per instance (change based on total memory and number of concurrent processes)
$numThreads = 2 # Number of threads per instance (recommended 2 to 4)
$delaySec = $delayMin * 60 # Delay between start of process.  This delays the plotting process
$logFolderPath = ".\Log\" # Name of the Log folder. can be relative (.\ ) or absolute (c:\)
#$poolPublicKey = "..." # uncomment and set to your public pool key. if not set, key from config.yaml is used
#$farmerPublicKey = "..." # lkcymmfkg and set your farmer public key.  If not set, key from config.yaml is used
$numberOfPlotsPerInstance = 1000 # This will give this number of plots per instance

# DO NOT CHANGE BELOW
$host.ui.RawUI.WindowTitle = "Chia Farmer: " + $tempPath + " Waiting " + $delayMin

$chiaDeamon = $env:LOCALAPPDATA + "\chia-blockchain\app-" + $chiaVersion + "\resources\app.asar.unpacked\daemon\chia.exe" 

# Creates a folder if does not exist; will not remove files if folder already present
New-Item -ItemType Directory -Path $logFolderPath -Force

Write-Output "Init Process to $tempPath Destination $destinationPath Memory $memBuffer threads $numThreads Delay $delayMin minutes" | Tee-Object -FilePath $logFile -Append
Write-Host "The Log folder is located at: $logFolderPath" # show to the user the actual path

# Create directory if it does not exist
New-Item -ItemType Directory -Force -Path $tempPath

# If you are staggaring your plotting, you can use this
Start-Sleep -Seconds $delaySec

# Start plotting - Infinite Loop
for ($instanceCount = 0;$instanceCount -lt $numberOfPlotsPerInstance;$instanceCount++) {

  # Delete all temporary files, in case previous run did not complete
  Get-ChildItem -Path $tempPath -Include *.tmp -File -Recurse  | foreach { $_.Delete()}

  $logFile = "$($logFolderPath)$($env:computername)$(Get-Date -Format "yyyy_MM_dd_HH_mm_ss")_$($instanceCount).log"

  # do not start plotting if the "stop" file exist at either temp or destination directory. 
  if ((Test-Path -Path "$destinationpath\stop.*" -PathType leaf) -or (Test-Path -Path "$tempPath\stop.*" -PathType leaf)) {
    Write-Output "Terminating instance due to STOP file found in either temp or destination path. Remove stop file and restart to continue plotting" | Tee-Object -FilePath $logFile -Append
    break
  }
  
  Write-Output "START Plotting $instanceCount to $tempPath Destination $destinationPath Memory $memBuffer threads $numThreads" | Tee-Object -FilePath $logFile -Append

  $host.ui.RawUI.WindowTitle = "Chia Farmer: " + $tempPath + " plotting " + $instanceCount
  if (($null -ne $poolPublicKey) -and ($null -ne $farmerPublicKey)) {
    # pass farmer and pool keys to chiaDeamon
    &$chiaDeamon  plots create -k 32 -f $farmerPublicKey -p $poolPublicKey -t $tempPath -d $destinationPath -b $memBuffer -r $numThreads | Out-File $logFile -Append
  }
  else {
    # use farmer and pool keys from config.yaml
    &$chiaDeamon  plots create -k 32 -t $tempPath -d $destinationPath -b $memBuffer -r $numThreads | Out-File $logFile -Append
  }
} 