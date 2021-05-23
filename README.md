# Plotting Automation Scripts

A collection of scripts for automating plotting activities of Chia Blockchain (https://github.com/Chia-Network/chia-blockchain)

## Prerequisites

Scripts developed for: 

* Windows 10 
* PowerShell (6/7)
* Chia for Windows 1.1.5 (https://github.com/Chia-Network/chia-blockchain/wiki/INSTALL#Windows)

## Script Overview

Scripts provides unattended plotting of cuncurrent instances of Chia on Windows computers.  

Benefits include:

* Command Line Interface (CLI)
* Staggered start time (in Minutes)
* 1 to many concurrent instances
* Detailed logging
* Use of intermediary storage to optimize plotting througput with optimized plot copy

## StartPlottingAll (startPlottingAll.ps1)

Schedules 1+ instance of Chia plotter with staggered time.

startPlottingAll uses the following parameters:

`-tempPath` for initial temp room directory. Each instance of plotter will use a sub-folders named P0, P1, etc. Phases 1, 2, 3 happen here.

For optimal performance separate plotting between multiple drives by calling StartPlottingAll once per drive.  This should be your fastest drive. (NVMe recommended).

`-destinationPath` for plot destination. Phase 4 happens here. This should be your next fastest drive (SATA SSD recommended) if you are using it as intermediary storage or slowest drive (SATA HDD, External USB2/3) if this is your final destination (source of farming)

`instanceCount` is the number of plotting instances to create.  Each instance will be started in staggered timeframe if `delayMin` is specified and use `tempPath`\sub-folder.  By default 1 instance is created.

Recommended concurrently is dependant on number of threads and cores available on your computer as well as number of temp drivers you want to use.

`delayMin` staggered start delay in Minutes.  Plotting will start after the number of minutes specified for each instance. Optimal delay is based on your system performance. Recommended is 40 min for most users. Default is to start immediately.

***Examples***

Start 3 plotting instances using drive D:\ as temp space and e:\ as destination with 40 min staggered start.
    This process will use folders D:\P0, D:\P1, D:\P2 as temp folders

```
.\startPlottingAll.ps1 d:\ e:\ 3 40
```

Start single plotting instances using drive D:\ as temp space and e:\ as destination immediately.
    This process will use folders D:\P0 as temp folders

```
.\startPlottingAll.ps1 d:\ e:\
```

Full named parameters:

```
.\startPlottingAll.ps1 -tempPath d:\ -destinationPath e:\ -instanceCount 3 -delayMin 30
```

## StartPlotting (startPlotting.ps1)

Starts a single instance of Chia plotter with 100 sequential plots.

startPlotting uses the following parameters:

`-tempPath` for initial temp directory. Phases 1, 2, 3 happen here. This should be your fastest drive. (NVMe recommended)

`-destinationPath` for plot destination. Phase 4 happens here. This should be your next fastest drive (SATA SSD recommended) if you are using it as intermediary storage or slowest drive (SATA HDD, External USB2/3) if this is your final destination (source of farming)

`delayMin` delay in Minutes.  Plotting will start after the number of minutes specified. Optimal delay is based on your system performance. Recommended is 40 min for most users. Default is 5 minutes.

You can also specify `farmer public key` and `pool public key` to be used in plotting by uncommenting `$farmerPublicKey` and `$poolPublicKey` variables and setting the corresponding values.  if they are not provided, deamon will use the keys specified in the config.yaml file.

#### Terminating Process ####

*Immediate*

The plotting will continue for number of iterations specified by $numberOfPlotsPerInstance, which should be set to a large number in most cases to allow fo continous plotting.

In case you want to terminate plots in progress, you can press Cntr+C in the PowerShell window to cancel the process or close the window.  Any plots in progress will be lost. Temp files created during the terminated ran will be removed if you re-start the process again.

*After Completing Plot in Progress*

If you can wait for plotting in progress to complete, create a file called 'stop' with any extention in either Temp or Destination folder.  Script will look for this file and if found, will exit as soon as it's done with plot in progress.

***Examples***

Start using drive D:\P1\ as temp space and e:\ as destination with 40 min delay. This process will use folders D:\P1 as temp folders

```
    .\startPlotting.ps1 d:\P1\ e:\ 40
```

Start single plotting using drived d:\P1\ as temp space and e:\ as destination immediately.

```
    .\startPlotting.ps1 d:\P1\ e:\ 0
```
Full named parameters:

```
    .\startPlotting.ps1 -tempPath d:\ -destinationPath e:\ -delayMin 30
```

### Move Plots between Drives (chia2drive.ps1)

This is a simple powershell script that uses `robocopy` to continously monitor and move compelted plots from one location (source) to another (destination).  

Script checks `tempPath` every 15 minutes.

`tempPath` - Location of the .plots to be moved from. this is  the storage where Chia deamon writes .plot files. 

`plotPath` - Location of the final destination where plots will be farmed. This is usually the slower drive (USB2/3, HHD)

`log` - Location of the log file.  c:\log\ is the default directory.

***Examples***

Moves files from D:\ to F:\ drive with log stored in c:\scripts\filelog.log directory.

```
.\chia2drive.ps1 d:\ f:\ c:\scripts\filelog.log
```