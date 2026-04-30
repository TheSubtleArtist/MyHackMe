# Windows Threat Detection

## Intro to Initial Access

### Exposed Services

Open ports, exposed to the open internet,  can be scanned by automated bots.  

Example MITRE Techniques:

[T1133 / External Remote Services (opens in new tab)](https://attack.mitre.org/techniques/T1133/): Threat actors will look for exposed RDP/VNC/SSH with weak passwords to get remote access to the machine
[T1190 / Exploit Public-Facing Application (opens in new tab)](https://attack.mitre.org/techniques/T1190/): Threat actors will look for misconfigured or vulnerable websites and applications

### User-Driven Methods

 Clicking malicious links  
 Launching phishing attachments  
 use of pirated software  
 Picking up / inserting unknown USB devices

 Example MITRE Techniques: 

[T1566 / Phishing](https://attack.mitre.org/techniques/T1566/): Threat actors employ different techniques, tricking users into launching the malware themselves
[T1091 / Removable Media](https://attack.mitre.org/techniques/T1091/): Threat actors infect a USB device and hope that users will use the USB on multiple PCs

## Inital Access via RDP

### Risks of Exposed RDB

### Detecting RDP Breach



| # | Step of Attack              | Description                                                                 | Detection Opportunity |
|---|----------------------------|-----------------------------------------------------------------------------|------------------------|
| 1 | Network Scan               | Botnet scans our IP and detects an exposed RDB port                            | N/A. Network attacks are out of the room scope |
| 2 | RDP Brute Force                | Botnet starts a brute force of common usernames (Administrator, admin, support, etc.) | 1. Open Security logs and filter for failed logins (Event ID 4625) <br> 2. Filter for logon types 3 and 10 (remote logons) <br> 3. Filter for logins from external IP sources (use "Source IP" field) <br> 4. This indicates a potential RDP brute force |
| 3 | Initial Access via RDP            | After ~100 attempts, the botnet guesses the correct password and enters the system | 1. Continue from previous step <br> 2. Switch filter to Event ID 4624 (successful logins) <br> 3. Check the account used for login <br> 4. Identify which account enabled initial access |
| 4 | Further Malicious Actions  | Two hours after the breach, the threat actor logs in via RDB and reviews the Desktop | 1. Continue from previous step <br> 2. Filter for logon type 10 (interactive RDP login) <br> 3. Copy the "Logon ID" from the event <br> 4. Search Sysmon logs for the same "Logon ID" <br> 5. Review all processes started by the threat actor |via RDP

### Logging Brute Force

![Logging-brute-force](images/intro-initial-access-103.png)  

## Initial Access via Phishing

### Current State of Phishing

Phishing attacks have increased at least 41x since the release of ChatGPT in 2022.  
High seccess rate  

### Binary Attachments

People are weary not to open unfamiliar `.exe` files.  
People are less familiar with less common extensions: `com`; `.scr`. or `.cpl`  
All have potential to carry and distribute malware  

Windows hides known file extensions by defult; allows attackers to miss malicious file extensions: `fake-invoice.pdf.exe`  

### LNK Attachments

Common method: make scripts look trustworthy by hiding them behind LNK shortcuts.  
Inserting malicious scripts as the "target"  

![lnk-target](images/intro-initial-access-104.png)  

LNK files leave littel execution trace.  
Name and icon of LNK file does not match the command executed from the `Target` field.

![lnk-event](images/intro-initial-access-106.png)  

### Detecting Malicious Download

executeables are possible.  
archives (.zip/.rar) far more likely  

#### Sysmon Event chain for Double-Extension Attachment  

```text
# 1. Sysmon Event ID 1: Web browser is launched
Image: C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
ParentImage: C:\Windows\Explorer.EXE

# 2. Sysmon Event ID 11: A file (usually archive) appears in Downloads
Image: C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
TargetFilename: C:\Users\User\Downloads\invoice.zip*

# 3. Sysmon Event ID 11: Optionally, the user unarchives files to some folder
Image: C:\Windows\Explorer.EXE (or C:\Program Files\7-Zip\7zG.exe)
TargetFilename: C:\Users\User\Downloads\invoice.pdf.exe

# 4. Sysmon Event ID 1: The user double-clicks the unarchived file
Image: C:\Users\User\Downloads\invoice.pdf.exe
ParentImage: C:\Windows\Explorer.EXE
````  

![sysmon-chain](images/intro-initial-access-105.svg)  


## Initial Access via USB

### Risks of Removable Media

[Camaro Dragon](https://research.checkpoint.com/2023/beyond-the-horizon-traveling-the-world-on-camaro-dragons-usb-flash-drives/) 

Camaro Dragon’s HopperTick/WispRider toolset is a robust USB‑propagating malware family combining social engineering, DLL side‑loading of malicious payloads via legitimate binaries, AV bypasses, and strong anti‑analysis measures — enabling wide, often collateral, global spread via removable media. Defenses should focus on removable-media controls, detection of suspicious side‑loading/persistence patterns, and preventing execution of unknown executables from USB drives.  

[Raspberry Robin](https://redcanary.com/blog/threat-intelligence/raspberry-robin/)  

The Red Canary analysis of “Raspberry Robin” describes a worm-like malware campaign first observed in 2021 that primarily spreads through infected USB drives, where it disguises itself as a shortcut (.LNK) file mimicking a legitimate folder to trick users into execution; once triggered, it uses cmd.exe to run obfuscated commands and then leverages the legitimate Windows Installer utility (msiexec.exe) to contact attacker-controlled infrastructure—often compromised QNAP devices or TOR-based nodes—and download a malicious DLL payload, which is executed via trusted Windows binaries like fodhelper.exe and rundll32.exe to evade detection and potentially gain elevated privileges. The malware establishes persistence, performs command-and-control communication, and can deliver additional payloads (including malware linked to ransomware operations), making it a versatile initial access and staging mechanism, though its ultimate objectives are not always clear; its reliance on removable media, living-off-the-land techniques, and staged payload delivery allows it to bypass traditional defenses and act as a precursor to more severe compromises.

### Detecting and Infected USB

A majority of USB exploits are executed by users.  

`.lnk` files.  
`photos.exe` : seemingly normal files with executable extensions  
double extensions  

![usb](images/intro-initial-access-107.svg)  

