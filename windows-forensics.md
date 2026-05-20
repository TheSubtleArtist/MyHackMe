# Windows Forensics

_Source timestamp: Saturday, July 29, 2023, 7:18 PM_

> Converted from a OneNote Word export into Markdown for rapid cybersecurity reference. Commands and lab steps are preserved from the source notes; use only in authorized lab or assessment environments.

### Forensic Artifacts:

- essential pieces of information

- provide evidence of human activity

- combined to recreate the story of how the crime was committed.

- often reside in locations 'normal' users won't typically venture to

### Windows tracks user activity

- primarily originat from Microsoft efforts to improve the user experience.

- Windows saves preferences

- forensic investigators use preferences as artifacts

### Windows Registry:

- collection of databases containing system configuration data

- hardware, the software, or the user's information

- data about the recently used files, programs used, or devices connected to the system

- consists of Keys and Values

- Structure of the Registry:

- The registry on any Windows system contains the following five root keys:

- HKEY_CURRENT_USER

- HKEY_USERS

- HKEY_LOCAL_MACHINE

- HKEY_CLASSES_ROOT

- HKEY_CURRENT_CONFIG

[Registry Hive](https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-hives)

- group of Keys, subkeys, and values stored in a single file on the disk.

- typically stored: C:\Windows\System32\config

  - DEFAULT (mounted on HKEY_USERS\DEFAULT)

  - SAM (mounted on HKEY_LOCAL_MACHINE\SAM)

  - SECURITY (mounted on HKEY_LOCAL_MACHINE\Security)

  - SOFTWARE (mounted on HKEY_LOCAL_MACHINE\Software)

  - SYSTEM (mounted on HKEY_LOCAL_MACHINE\System)

- user hives are hidden files: C:\Users\<username>

  - NTUSER.DAT (mounted on HKEY_CURRENT_USER when a user logs in)

  - USRCLASS.DAT (mounted on HKEY_CURRENT_USER\Software\CLASSES)

    - C:\Users|<username>\AppData\Local\Microsoft\Windows

### The Amcache Hive:

- located in C:\Windows\AppCompat\Programs\Amcache.hve

- saves information on programs that were recently run on the system.

### Transaction Logs:

- transaction logs used when writing data to registry hives

- often have the latest changes in the registry that haven't made their way to the registry hives themselves

- log for each hive is stored as a .LOG file in the same directory as the hive itself

- same name as the registry

- can be multiple transaction logs: will have .LOG1, .LOG2 etc., as their extension

- It is prudent to look at the transaction logs as well when performing registry forensics.

### Registry backups

- opposite of Transaction logs

- backups located in the C:\Windows\System32\Config directory

- copied to the C:\Windows\System32\Config\RegBack directory every ten days

### Data Acquisition

- live system or an image taken of the system

- image the live system or make a copy of the required data and perform forensics on the copy

- registry hives from %WINDIR%\System32\Config, we cannot because it is a restricted file. So, what to do now

### Kape:

- live data acquisition and analysis

- used to acquire registry data.

- primarily a command-line

### Autopsy:

- acquire data from both live systems or from a disk image

- navigate to the location of the files you want to extract, then right-click and select the Extract File(s) option.

### FTK Imager:

- similar to Autopsy

- allows you to extract files from a disk image or a live system

- mounts the disk image or drive in FTK Imager

- Another way you can extract Registry files from FTK Imager is through the Obtain Protected Files option. This option is only available for live systems and is highlighted in the screenshot below. This option allows you to extract all the registry hives to a location of your choosing. However, it will not copy the Amcache.hve file, which is often necessary to investigate evidence of programs that were last executed.

### Zimmerman's Registry Explorer:

- can load multiple hives simultaneously and add data from transaction logs into the hive to make a more 'cleaner' hive

- has a handy 'Bookmarks' option containing forensically important registry keys often sought by forensics investigators.

- Investigators can go straight to the interesting registry keys and values with the bookmarks menu item

- Registry Explorer allows sort data contained in registry keys.

- also lists the Last Opened time of the files

### RegRipper:

- takes a registry hive as input and outputs a report that extracts data from some of the forensically important keys and values in that hive.

- shows all the results in sequential order.

- both a CLI and GUI forms

- does not take the transaction logs into account.

### Time Zone Information:

- For accuracy, it is important to establish what time zone the computer is located in.

- some data in the computer will have their timestamps in UTC/GMT

- Knowledge of the local time zone helps in establishing a timeline when merging data from all the sources.

- understand the chronology of the events as they happened

- finding the Time Zone Information: SYSTEM\CurrentControlSet\Control\TimeZoneInformation

### Network Interfaces and Past Networks:

- list of network interfaces on the machine we are investigating: SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces

- Each Interface is represented with a unique identifier (GUID) subkey, which contains values relating to the interface's TCP/IP configuration. This key will provide us with information like IP addresses, DHCP IP address and Subnet Mask, DNS Servers, and more. This information is significant because it helps you make sure that you are performing forensics on the machine that you are supposed to perform it on.

- past networks a given machine was connected to can be found in the following locations:

  - SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged

  - SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Managed

  - These registry keys contain past networks as well as the last time they were connected. The last write time of the registry key points to the last time these networks were connected.

### Autostart Programs (Autoruns):

- The following registry keys include information about programs or commands that run when a user logs on.

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Run

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\RunOnce

- SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce

- SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\Run

- SOFTWARE\Microsoft\Windows\CurrentVersion\Run

- SYSTEM\CurrentControlSet\Services

- if the start key is set to 0x02, this means that this service will start at boot.

### SAM hive and user information:

- contains user account information, login information, and group information.

| -mainly located in the following location: kali | SAM\Domains\Account\Users |
| --- | --- |

### Recent Files:

- stored in the NTUSER hive and can be found on the following location:

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

- different keys with file extensions, such as .pdf, .jpg, .docx etc

- looking specifically for the last used PDF files, we can look at the following registry key:

NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs\.pdf

### Office Recent Files:

- located in the NTUSER hive:

- NTUSER.DAT\Software\Microsoft\Office\VERSION

- version number for each Microsoft Office release is different

- example registry key:

- NTUSER.DAT\Software\Microsoft\Office\15.0\Word

- Office 365 ties the location to the user's [live ID](https://www.microsoft.com/security/blog/2008/05/07/what-is-a-windows-live-id/). recent files found at:

- NTUSER.DAT\Software\Microsoft\Office\VERSION\UserMRU\LiveID_####\FileMRU

### ShellBags:

- information about Windows 'shell' is stored; can identify Most Recently Used files and folders

- setting different for each user; located in the user hives:

USRCLASS.DAT\Local Settings\Software\Microsoft\Windows\Shell\Bags

USRCLASS.DAT\Local Settings\Software\Microsoft\Windows\Shell\BagMRU

NTUSER.DAT\Software\Microsoft\Windows\Shell\BagMRU

NTUSER.DAT\Software\Microsoft\Windows\Shell\Bags

- Eric Zimmerman's ShellBag Explorer shows the information

### Open/Save and LastVisited Dialog MRUs:

- Windows stores open/save a file at a specific location:

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePIDlMRU

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU

### Windows Explorer Address/Search Bars:

- Windows Explorer address bar or searches performed:

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery

### UserAssist:

- information about the programs launched, the time of their launch, number of times executed

- programs run using the command not tracked in the User Assist keys

- in the NTUSER hive, mapped to each user's GUID:

NTUSER.DAT\Software\Microsoft\Windows\Currentversion\Explorer\UserAssist\{GUID}\Count

Take a look at the below screenshot from Registry Explorer and answer Question #1.

### ShimCache:

- also called Application Compatibility Cache (AppCompatCache)

- keeps track of application compatibility with the OS

- tracks all applications launched on the machine

- stores file name, file size, and last modified time of the executables.

- main purpose: ensure backward compatibility of applications

- located in the SYSTEM hive:

- SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache

- Eric Zimmerman's AppCompatCache Parser takes the SYSTEM hive as input, parses the data, and outputs a CSV file

- AppCompatCacheParser.exe --csv <path to save output> -f <path to SYSTEM hive for data parsing> -c <control set to parse>

- output viewed using Eric Zimmerman's EZviewer

### AmCache:

- The AmCache hive is an artifact related to ShimCache

- stores additional data related to program executions

- execution path, installation, execution and deletion times, and SHA1 hashes of the executed programs

- located in the file system at:

- C:\Windows\appcompat\Programs\Amcache.hve

- Information about the last executed programs found at:

Amcache.hve\Root\File\{Volume GUID}\

### Bam/Dam:

- Background Activity Monitor or BAM tracks activity of background applications

- Desktop Activity Moderator or DAM optimizes power consumption of the device

- Both part of MS Windows Modern Standby system

- information about last run programs, their full paths, and last execution time:

- SYSTEM\CurrentControlSet\Services\bam\UserSettings\{SID}

- SYSTEM\CurrentControlSet\Services\dam\UserSettings\{SID}

### Device identification:

- locations tracking USB keys plugged into a system

- store the vendor id, product id, and version of the USB device, and time plugged in

- SYSTEM\CurrentControlSet\Enum\USBSTOR

- SYSTEM\CurrentControlSet\Enum\USB

- Registry Explorer shows this information

### First/Last Times:

- tracking first time the device was connected, the last time it was connected and last time the device was removed from the system:

- SYSTEM\CurrentControlSet\Enum\USBSTOR\Ven_Prod_Version\USBSerial#\Properties\{83da6326-97a6-4088-9453-a19231573b29}\####

- the #### sign can be replaced by the following digits to get the required information:

| -Value | Information |
| --- | --- |
| -0064 | First Connection time |
| -0066 | Last Connection time |
| -0067 | Last removal time |

- Registry Explorer parses and shows USBSTOR key.

### USB device Volume Name:

- device name found at:

- SOFTWARE\Microsoft\Windows Portable Devices\Devices

- can compare the GUID we see here with the Disk ID we see on keys mentioned in device identification to correlate the names with unique devices

- Combining information creates picture of any USB devices connected to the machine

### The Setup:

### Username: THM-4n6

### Password: 123

Once we log in, we will see two folders on the Desktop named triage and EZtools. The triage folder contains a triage collection collected through KAPE, which has the same directory structure as the parent. This is where our artifacts will be located. The EZtools folder contains Eric Zimmerman's tools, which we will be using to perform our analysis. You will also find RegistryExplorer, EZViewer, and AppCompatCacheParser.exe in the same folder.

### The Challenge:

Now that we know where the required toolset is, we can start our investigation. We will have to use our knowledge to identify where the different files for the relevant registry hives are located and load them into the tools of our choice. Let's answer the questions below using our knowledge of registry forensics.

### Scenario:

One of the Desktops in the research lab at Organization X is suspected to have been accessed by someone unauthorized. Although they generally have only one user account per Desktop, there were multiple user accounts observed on this system. It is also suspected that the system was connected to some network drive, and a USB device was connected to the system. The triage data from the system was collected and placed on the attached VM. Can you help Organization X with finding answers to the below questions?

Note: When loading registry hives in RegistryExplorer, it will caution us that the hives are dirty. This is nothing to be afraid of. We just need to remember the little lesson about transaction logs and point RegistryExplorer to the .LOG1 and .LOG2 files with the same filename as the registry hive. It will automatically integrate the transaction logs and create a 'clean' hive. Once we tell RegistryExplorer where to save the clean hive, we can use that for our analysis and we won't need to load the dirty hives anymore. RegistryExplorer will guide you through this process.

### Answer the questions below:

- Resource: https://05t3.github.io/posts/Windows-Forensics-1/

### How many user created accounts are present on the system?

- Loaded all the hives into Registry Explorer

- when asked, ran all the log files against the dirty hives to result in the clean hives

- Security Hive had a bunch of users, but only three had extremely long SID

- Dive into the SAM hive > Domains > Account > Users

- Answer: 3

### What is the username of the account that has never been logged in?

- in the same hive / location

- there is column "Last Login"

- one user has an empty spot

- Answer: thm-user2

### What's the password hint for the user THM-4n6?

- Same location

- "password hint" column

- Answer: Count

### When was the file 'Changelog.txt' accessed?

- NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

- Answer: 2021-11-24 18:18:48

### What is the complete path from where the python 3.8.2 installer was run?

- Search for "userassist"; but, subkeys do not show up. Once you know where the resource is you must clear out the search and drill down to the thing you are looking for.

- drill down into SOFTWARE > Micorosft > Windows > CurrentVersion>Explorer>UserAssist

- C:\Users\THM-4n6\Desktop\UpdatedFiles\NTUSER.DAT_clean2: SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}\Count

- entered "python" in to the "Program Name" column as a filter

- Answer: Z:\setups\python-3.8.2.exe

### When was the USB device with the friendly name 'USB' last connected?

- First: SYSTEM\CurrentControlSet\Enum\USBSTOR

- there were two US devices

- Try both

- Answer: 2021-11-24 18:40:06

### The File Allocation Table (FAT):

- not the default windows file system anymore.

- creates a table that indexes the location of bits that are allocated to different files.

- bits that make up a file are stored in clusters

- All filenames on a file system, their starting clusters, and their lengths are stored in directories

- location of each cluster on the disk is stored in the File Allocation Table.

.

### Data structures of the FAT file system:

### Clusters:

- basic storage unit

- Each file considered a group of clusters containing bits of information.

### Directory:

- contains information about file identification

- file name, starting cluster, and filename length.

### File Allocation Table:

- linked list of all the clusters

- contains status of the cluster and the pointer to the next cluster in the chain.

### FAT12, FAT16, and FAT32:

- FAT file format divides the available disk space into clusters for addressing.

- FAT: 8-bit clustersThe number of these clusters depends on the number of bits used to address the cluster

- FAT12: 12-bit clusters; max 4096 clusters (2^12)

- FAT16: 16-bit clusters; max 2^16 clusters (65,536)

- FAT32: 28-bit clusters; max 2^28 clusters; Other four bits are for admin / meta-data

| Attribute | FAT12 | FAT16 | FAT32 |
| --- | --- | --- | --- |
| Addressable bits | 12 | 16 | 28 |
| Max number of clusters | 4,096 | 65,536 | 268,435,456 |
| Supported size of clusters | 512B - 8KB | 2KB - 32KB | 4KB - 32KB |
| Maximum Volume size | 32MB | 2GB | 2TB |

- FAT16 and FAT32 still used in USB drives, SD cards, or Digital cameras

- maximum volume size and the maximum file size reduced usage.

### The exFAT file system:

- default for SD cards larger than 32GB

- adopted widely by manufacturers of digital devices

- supports a cluster size of 4KB to 32MB

- maximum file size and a maximum volume size of 128PB (Petabytes)

- reduces some overheads of FAT file system; lighter and more efficient

- maximum 2,796,202 files per directory.

### The NTFS file system

- New Technology File System (NTFS)

### Journaling

- log of changes to the metadata in the volume

- helps the system recover from a crash or data movement due to defragmentation

- stored in $LOGFILE in the volume's root directory

### Access Controls

- FAT file system did not have access controls based on the user

- NTFS has access controls that define the owner of a file/directory and permissions for each user.

### Volume Shadow Copy

- tracks changes made to a file using a feature called Volume Shadow Copies

- allows a userto restore previous file versions for recovery or system restore

- ransomware actors delete the shadow copies on a victim's file systems to prevent them from recovering their data.

### Alternate Data Streams

- A file is a stream of data organized in a file system

- Alternate data streams (ADS) is a feature in NTFS

- allows files to have multiple streams of data stored in a single file

- browsers use Alternate Data Streams to identify files downloaded from the internet (using the ADS Zone Identifier)

- Malware has also been observed to hide their code in ADS.

### Master File Table

- much more extensive than the File Allocation Table

- structured database tracks objects stored in a volume

- critical files in the MFT:

$MFT

- first record in the volume

- Volume Boot Record (VBR) points to the cluster where $MFT is located

- stores information about the clusters where all other objects present on the volume are located

- contains a directory of all the files present on the volume.

$LOGFILE

- stores the transactional logging of the file system

- helps maintain integrity of the file system in the event of a crash.

$UsnJrnl

- Update Sequence Number (USN) Journal

- present in the $Extend record

- contains information about all files changed in the file system and the reason for the change

- also called the change journal.

### MFT Explorer

Eric Zimmerman's tool used to explore MFT files

- available in both command line and GUI versions

Parse the $MFT file placed in C:\users\THM-4n6\Desktop\triage\C\ and analyze it. What is the Size of the file located at .\Windows\Security\logs\SceSetupLog.etl

- Command: MFTECmd.exe -f <path-to-$MFT-file> --csv <path-to-save-results-in-csv>

What is the size of the cluster for the volume from which this triage was taken?

### Deleted files and Data recovery:

- File delete deletes entries storing file's location on the disk

- the file contents not deleted until overwritten by another file or by the disk firmware performing maintenance

- there is data in different unallocated clusters, which can possibly be recovered

- recovery means understanding the file structure of different file types

- identify the specific file through the data we see in a hex editor

### Disk Image:

- bit-by-bit copy of a disk drive

- saves all data in a disk image file, including the metadata, in a single file

- allows several copies of the physical evidence

- 1) The original evidence is not contaminated while performing forensics

- 2) The disk image file can be copied to another disk and analyzed without using specialized hardware.

### Recovering files using Autopsy

With that out of the way, let's see how we can recover deleted files from a disk. We will use Autopsy for recovering deleted files.

### Windows Prefetch files

- When a program is run in Windows, it stores its information for future use.

- stored information is used to load the program quickly in case of frequent use.

- information is stored in prefetch files: C:\Windows\Prefetch directory.

- extension: .pf

- contain last run times of the application, the number of times the application was run, and any files and device handles used by the file

- excellent source of information about the last executed programs and files.

- Prefetch Parser (PECmd.exe) from Eric Zimmerman's tools parses Prefetch files and extracts data

- parse and save results in a CSV: PECmd.exe -f <path-to-Prefetch-files> --csv <path-to-save-csv>

- parseing a whole directory: PECmd.exe -d <path-to-Prefetch-directory> --csv <path-to-save-csv>

### Windows 10 Timeline

- stores recently used applications and files in an SQLite database

- source of information about the last executed programs

- contains application executed and focus time

- location: C:\Users\<username>\AppData\Local\ConnectedDevicesPlatform\{randomfolder}\ActivitiesCache.db

- Eric Zimmerman's WxTCmd.exe parses Windows 10 Timeline.

- Command: WxTCmd.exe -f <path-to-timeline-file> --csv <path-to-save-csv>

### Windows Jump Lists

- helps users go directly recently used files from the taskbar

- view by right-clicking an application's icon in the taskbar

- data is stored: C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations

- includes information about the applications executed, first time of execution, and last time of execution of the application against an AppID.

- command to parse Jumplists: JLECmd.exe -f <path-to-Jumplist-file> --csv <path-to-save-csv>

### Shortcut Files

- Windows creates a shortcut file for each file opened either locally or remotely

- contains information about the first and last opened times of the file and the path of the opened file, other data

- locations:

- C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\

- C:\Users\<username>\AppData\Roaming\Microsoft\Office\Recent\

- use Eric Zimmerman's LECmd.exe (Lnk Explorer) to parse Shortcut files

- LECmd.exe -f <path-to-shortcut-files> --csv <path-to-save-csv>

### IE/Edge history

- IE/Edge browsing includes files opened in the system as well

- access the history in the following location:

- C:\Users\<username>\AppData\Local\Microsoft\Windows\WebCache\WebCacheV*.dat

- files/folders accessed appear with a [file:///*](file://*) prefix in the IE/Edge history

- several tools can be used to analyze Web cache data

- Autopsy: selectLogical Files as a data source.

### Setupapi dev logs for USB devices

- When any new device is attached to a system

- information related to the setup stored in setupapi.dev.log

- log location: C:\Windows\inf\setupapi.dev.log

- contains device serial number, first/last times connected

- open in notepad.

- information may also appear in Shortcuts
