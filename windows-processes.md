# Windows Processes

_Source timestamp: Friday, April 28, 2023, 7:28 AM_

> Converted from a OneNote Word export into Markdown for rapid cybersecurity reference. Commands and lab steps are preserved from the source notes; use only in authorized lab or assessment environments.

### Task Manager

- what is running

- resource usage

- "kill" processes

### Task Manager Details Tab

- Process Types: Apps, Background, or Windows

- Publsher: author of the program/file

- PID: process identifier; unique to the current instantiation of the process

- Process Name: file name of the process

- Command Line: full command used to lauch the process

- CPU: amount of CPU the process uses

- Memory: amount of physical memory utilized by the process

- additional columns available

- "Image path name" and "Command Line" have information which can alert an analyst about an outlier process

### PROCESS HACKER and PROCESS EXPLORER

- Reveals parent-child process views

- command line equivalents are: tasklist, GET-PROCESS or PS in powershell, and WMIC

- User Mode: creates "process" for the application; process provides private virtual address space and private handle table; prevents application can't alter data of another application; each app runs in isolation

- Kernel Mode: all code shares a signe virtual address space; not isolated from other drivers or the operating system; one crash impacts entire OS

- "SYSTEM" PID should always be 4

### SESSION MANAGER SUBSYSTEM (smss.exe)

- AKA Windows Session Manager

- first user mode process started by the Kernel; Reference: https://en.wikipedia.org/wiki/Architecture_of_Windows_NT

- subsequently starts the win32k.sys (kernel mode), winserve.dll (user mode), and csrss,exe (user mode

- starts csrss.exe (winodws subsystem) and wininit.exe in Session 0 (isolated Windows session for the operating system)

- starts winlogon,exe and another csrss.exe in Session 1 (user session)

- The first child instances creates child instances using smss.exe by copying itself into the new session and self-terminating; -Reference: https://en.wikipedia.org/wiki/Session_Manager_Subsystem

- creates environment variables, virtula memory paging files, and starts winlogon.exe

- Normal Parameters:

Image Path: %SystemRoot%\System32\smss.exe

### Parent Process: System

Number of Instances: One master instance and child instance per session. The child instance exits after creating the session.

### User Account: Local System

### Start Time: Within seconds of boot time for the master instance

- Identifying unusual parameters:

  - A different parent process other than System (4)

  - The image path is different from C:\Windows\System32

  - More than one running process. (children self-terminate and exit after each new session)

  - The running User is not the SYSTEM user

  - Unexpected registry entries for Subsystem

### Client Server Runtime Process (csrss.exe)

- user-mode side of Windows subsystem

- always running

- critical to system oepration

- termination results in system failure

- responsible for Win32 console window and process thread creation / deletion

- each instance of csrss.exe three important dll's (ando others) are loaded (csrsrv.dll, basesrv.dll, winsrv.dll)

- makes Windows API available to other processes, ampping drive letters, and handing Windows shutdown

- reference: https://en.wikipedia.org/wiki/Client/Server_Runtime_Subsystem

- Normal Parameters:

Image Path: %SystemRoot%\System32\csrss.exe

### Parent Process: Created by an instance of smss.exe

### Number of Instances: Two or more

### User Account: Local System

Start Time: Within seconds of boot time for the first two instances (for Session 0 and 1). Start times for additional instances occur as new sessions are created, although only Sessions 0 and 1 are often created.

- Unusual Parameters:

### An actual parent process. (smss.exe calls this process and self-terminates)

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes masquerading as csrss.exe in plain sight

- The user is not the SYSTEM user.

### Pid History

- gpedit.msc

- Local Computer Policy \ Computer Configuration \ Windows Settings \ Security Settings \ Local Policies \ Audit Policy \ Audit Process Tracking

- Event Viewer

### Windows Initialization Process (wininit.exe)

- launches Service Control Manager (services.exe)

- launches Local Security Authority (lsass.exe

- launches lsaiso.exe when Credential Guard is enabled

- Normal:

Image Path: %SystemRoot%\System32\wininit.exe

### Parent Process: Created by an instance of smss.exe

### Number of Instances: One

### User Account: Local System

### Start Time: Within seconds of boot time

- Identify Unusual

### An actual parent process. (smss.exe calls this process and self-terminates)

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes in plain sight

### Multiple running instances

### Not running as SYSTEM

### SERVICES CONTROL MANAGER (services.exe)

- maintains a database which can be queries with the command "sc.exe"

- located in the registry: HKLM\System\CurrentControlSet\Services

- loads and interacts with services

- starts and ends services

- loads device drivers marked as "auto-start"

- loads Last Known Good Configuration into CurrentControlSet; happens when user logsin; registry location is HKLM\System\Select\LastKnownGood

- parent to: svchost.exe, spoolsv.exe, msmpeng.exe, and dllhost.exe

- reference: https://en.wikipedia.org/wiki/Service_Control_Manager

- Normal

Image Path: %SystemRoot%\System32\services.exe

### Parent Process: wininit.exe

### Number of Instances: One

### User Account: Local System

### Start Time: Within seconds of boot time

- Identifying Unusual:

### A parent process other than wininit.exe

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes in plain sight

### Multiple running instances

### Not running as SYSTEM

```text
SERVICE HOST (svchost.exe)
```

- hosts and manages Windows services

- services running in this process are implemented as DLLs

- registry: HKLM\SYSTEM\CurrentControlSet\Services\<Service Name>\Parameters

- Binary path includes a "-k" flag which must be present if a legitimate svchost.exe process is called

- "-k": groups similar services to share the same process; reduces resource consumption;

- runs multiple processes on any Windows system, making it a significant target for threat actors;

- Normal

Image Path: %SystemRoot%\System32\svchost.exe

### Parent Process: services.exe

### Number of Instances: Many

User Account: Varies (SYSTEM, Network Service, Local Service) depending on the svchost.exe instance. In Windows 10, some instances run as the logged-in user.

### Start Time: Typically within seconds of boot time. Other instances of svchost.exe can be started after boot.

- Identifying Unusual

### A parent process other than services.exe

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes in plain sight

### The absence of the -k parameter

### Local Security Authority Subsystem Service (lsass.exe)

- enforces security policy on the system

- verfies users logging into a machine or server

- handles password chngaes

- creates access tokens for Secuiryt Account Manager (SAM), Active Directory (AD), and NETLOGON

- writes to Windows Security Log

- Authentication packages stored in: HKLM\System\CurrentControlSet\Control\Lsa

- targeted by users of mimikatz to dump credentials;

- Normal

Image Path: %SystemRoot%\System32\lsass.exe

### Parent Process: wininit.exe

### Number of Instances: One

### User Account: Local System

### Start Time: Within seconds of boot time

- Identifying unusual

### A parent process other than wininit.exe

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes in plain sight

### Multiple running instances

### Not running as SYSTEM

### Windows Logon (winlogon.exe)

- handles the Secure Attention Sequence (SAS)

- users employ the CTRL+ALT+DELETE combination to enter the username password for logon

- loads the user profile into the HKCU,

- user profile is stored in the user's NTUSER.DAT

- the userinit.exe component loads the user's shell: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc939862(v=technet.10)?redirectedfrom=MSDN

- locks the screen and runs screensaver, among other functions: https://en.wikipedia.org/wiki/Winlogon

- is launched by SMSS.exe into session 1

- Registry Location: KEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon

- Normal

Image Path: %SystemRoot%\System32\winlogon.exe

Parent Process: Created by an instance of smss.exe that exits, so analysis tools usually do not provide the parent process name.

### Number of Instances: One or more

### User Account: Local System

Start Time: Within seconds of boot time for the first instance (for Session 1). Additional instances occur as new sessions are created, typically through Remote Desktop or Fast User Switching logons.

- Identify unusual?

### An actual parent process. (smss.exe calls this process and self-terminates)

- Image file path other than C:\Windows\System32

### Subtle misspellings to hide rogue processes in plain sight

### Not running as SYSTEM

### Shell value in the registry other than explorer.exe

### Windows Explorer (explorer.exe)

- provides user access to folders and files

- additioanl functioanirty for Start Menu and Taskbar

- Registry location: HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon\Shell

- Userinit.exe exists after spawning explorer. Exe; parent process is non-existent

- many child processe

- Normal

Image Path: %SystemRoot%\explorer.exe

### Parent Process: Created by userinit.exe and exits

### Number of Instances: One or more per interactively logged-in user

### User Account: Logged-in user(s)

### Start Time: First instance when the first interactive user logon session begins

### Identify unusual?

### An actual parent process. (userinit.exe calls this process and exits)

- Image file path other than C:\Windows

### Running as an unknown user

### Subtle misspellings to hide rogue processes in plain sight

### Outbound TCP/IP connections
