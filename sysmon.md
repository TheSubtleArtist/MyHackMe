# Sysmon

## Introduction

Sysmon is a Windows Sysinternals tool used to monitor and log Windows endpoint activity. For SOC work, its value is that it records high-fidelity host telemetry that normal Windows logs often do not capture clearly enough for detection, triage, and attack reconstruction.

Operationally, Sysmon helps analysts answer rapid-response questions such as:

- What process executed?
- What command line did it use?
- What process launched it?
- What network destination did it contact?
- What files, registry keys, or alternate data streams did it create?
- Did it access sensitive processes such as `lsass.exe`?
- Did it attempt injection, persistence, or command-and-control activity?

## Sysmon Overview

Sysmon gathers detailed logs and event tracing that help identify anomalies in a Windows environment. When installed, Sysmon starts early in the Windows boot process, which improves visibility into activity that occurs before a user begins normal interaction.

Sysmon events are stored at:

```text
Applications and Services Logs/Microsoft/Windows/Sysmon/Operational
```

### Config Overview

Sysmon requires a configuration file to tell the binary which events to collect, include, exclude, and label. You can create a custom configuration or start from community configurations such as:

- [SwiftOnSecurity Sysmon config](https://github.com/SwiftOnSecurity/sysmon-config)
- [ION-Storm Sysmon config](https://github.com/ion-storm/sysmon-config)

A strong Sysmon configuration reduces noise while preserving the events that matter. Many mature configurations use more `exclude` rules than `include` rules because it is usually safer to collect broadly and suppress known-good activity than to collect only a narrow set of known-bad conditions.

ION-Storm-style configurations may use more proactive include logic. This can be useful for focused hunting, but the analyst must understand what the rule set is suppressing or emphasizing.

## Event ID Rapid Reference

| Event ID | Event name | Primary SOC use | Key fields / XML tags | Rapid interpretation |
|---:|---|---|---|---|
| 1 | Process Creation | Identify executed binaries, command lines, parent/child process chains, and suspicious process names or paths. | `Image`, `CommandLine`, `ParentImage`, `ParentCommandLine`, `User`, `ProcessId` | Start here when reconstructing what ran on the endpoint. |
| 3 | Network Connection | Detect suspicious outbound or inbound connections, common C2 ports, RAT ports, and unexpected process-to-network activity. | `Image`, `DestinationIp`, `DestinationPort`, `Protocol` | Use with process context to determine whether a network event is malicious or expected. |
| 7 | Image Loaded | Detect DLL loading, DLL hijacking, and DLL injection indicators. | `Image`, `ImageLoaded`, `Signed`, `Signature` | High-volume event; use carefully because it can create heavy system load and alert noise. |
| 8 | CreateRemoteThread | Detect process injection, thread hijacking, process hollowing, and related evasion behavior. | `SourceImage`, `TargetImage`, `StartAddress`, `StartFunction` | A process creating a thread inside another process is often suspicious unless clearly explained by normal software behavior. |
| 10 | ProcessAccess | Hunt for suspicious access to sensitive processes such as LSASS. | `SourceImage`, `TargetImage`, access details | Access to `lsass.exe` by unexpected processes can indicate credential dumping. |
| 11 | File Created | Detect malware drops, ransomware notes, suspicious scripts, and payload staging. | `TargetFilename` | File creation in user-writable or staging paths deserves attention. |
| 12 / 13 / 14 | Registry Event | Detect registry changes used for persistence, configuration tampering, or credential abuse. | `TargetObject` | Registry modification is often the strongest persistence clue. |
| 15 | FileCreateStreamHash | Detect Alternate Data Streams (ADS) used to hide payloads. | `TargetFilename` | ADS activity can reveal files hidden from normal directory inspection. |
| 22 | DNS Query | Detect suspicious domains after filtering known-good DNS noise. | `QueryName` | Useful for C2 discovery when paired with process and network connection events. |

## Event ID Configuration Examples

### Event ID 1: Process Creation

Process creation events detect newly created processes. For rapid triage, review the process path, command line, parent process, user context, and whether the process name or spelling looks suspicious.

```xml
<RuleGroup name="" groupRelation="or">
  <ProcessCreate onmatch="exclude">
    <CommandLine condition="is">C:\Windows\system32\svchost.exe -k appmodel -p -s camsvc</CommandLine>
  </ProcessCreate>
</RuleGroup>
```

This rule excludes a known `svchost.exe` command line from logging. The operational goal is to suppress known-good background activity so analyst attention stays on unusual process launches.

### Event ID 3: Network Connection

Network connection events identify remote activity, suspicious binaries communicating over the network, and open ports associated with exploitation, RATs, or command-and-control channels.

```xml
<RuleGroup name="" groupRelation="or">
  <NetworkConnect onmatch="include">
    <Image condition="image">nmap.exe</Image>
    <DestinationPort name="Alert,Metasploit" condition="is">4444</DestinationPort>
  </NetworkConnect>
</RuleGroup>
```

This rule includes connections involving `nmap.exe` and connections to destination port `4444`, a port commonly associated with Metasploit handlers. A matching event should trigger investigation into the process, source host, destination, and surrounding timeline.

### Event ID 7: Image Loaded

Image load events detect DLLs loaded by processes. This is useful for DLL injection and DLL hijacking hunts, but it can generate significant volume.

```xml
<RuleGroup name="" groupRelation="or">
  <ImageLoad onmatch="include">
    <ImageLoaded condition="contains">\Temp\</ImageLoaded>
  </ImageLoad>
</RuleGroup>
```

DLLs loaded from `\Temp\` are suspicious because legitimate application DLLs typically load from application, system, or trusted installation paths. Investigate the loading process, the DLL hash, and whether the DLL was recently created.

### Event ID 8: CreateRemoteThread

CreateRemoteThread events monitor processes that create threads inside other processes. This behavior can be legitimate, but it is also used by malware to hide execution inside trusted processes.

```xml
<RuleGroup name="" groupRelation="or">
  <CreateRemoteThread onmatch="include">
    <StartAddress name="Alert,Cobalt Strike" condition="end with">0B80</StartAddress>
    <SourceImage condition="contains">\</SourceImage>
  </CreateRemoteThread>
</RuleGroup>
```

The first condition hunts for a memory-address pattern associated with Cobalt Strike indicators. The second condition helps identify injected processes that may not have a clear parent process relationship. Treat these events as high-value leads for injection and evasion analysis.

### Event ID 11: File Created

File creation events identify files written or overwritten on the endpoint. They are useful for detecting dropped payloads, scripts, ransomware notes, and staging files.

```xml
<RuleGroup name="" groupRelation="or">
  <FileCreate onmatch="include">
    <TargetFilename name="Alert,Ransomware" condition="contains">HELP_TO_SAVE_FILES</TargetFilename>
  </FileCreate>
</RuleGroup>
```

This example hunts for ransomware-style file creation. When a matching file appears, pivot to the creating process, parent process, user context, and nearby network activity.

### Event ID 12 / 13 / 14: Registry Event

Registry events detect changes or modifications to the Windows registry. Malicious registry activity often supports persistence, configuration tampering, defense evasion, or credential abuse.

```xml
<RuleGroup name="" groupRelation="or">
  <RegistryEvent onmatch="include">
    <TargetObject name="T1484" condition="contains">Windows\System\Scripts</TargetObject>
  </RegistryEvent>
</RuleGroup>
```

This rule looks for registry objects under `Windows\System\Scripts`, a location adversaries may use to configure scripts for persistence or policy-based execution.

### Event ID 15: FileCreateStreamHash

FileCreateStreamHash detects files created in Alternate Data Streams. ADS can hide content from normal directory listing and is a known malware evasion technique.

```xml
<RuleGroup name="" groupRelation="or">
  <FileCreateStreamHash onmatch="include">
    <TargetFilename condition="end with">.hta</TargetFilename>
  </FileCreateStreamHash>
</RuleGroup>
```

This rule hunts for `.hta` files placed inside alternate data streams. `.hta` content can be executed by `mshta.exe`, so this event can indicate script-based payload execution.

### Event ID 22: DNS Event

DNS query events capture domain lookups. Because DNS logs can be noisy, a common approach is to exclude trusted high-volume domains first and then hunt for suspicious or rare domains.

```xml
<RuleGroup name="" groupRelation="or">
  <DnsQuery onmatch="exclude">
    <QueryName condition="end with">.microsoft.com</QueryName>
  </DnsQuery>
</RuleGroup>
```

This rule excludes Microsoft domains to reduce noise. After filtering known-good domains, review remaining queries for suspicious TLDs, randomized-looking names, newly observed domains, or domains associated with known malware infrastructure.

## Installing and Preparing Sysmon

Use Sysinternals tools and a chosen Sysmon configuration file.

```powershell
Download-SysInternalsTools C:\Sysinternals
```

Configuration examples:

- ION-Storm config: <https://github.com/ion-storm/sysmon-config/blob/develop/sysmonconfig-export.xml>
- SwiftOnSecurity config: <https://github.com/SwiftOnSecurity/sysmon-config>

## Cutting Out the Noise

[Event-File](assets/sysmon-task04.evtx)  

### Malicious Activity Overview

A well-built Sysmon configuration filters out normal activity so analysts can focus on meaningful events. In active monitoring, do not rely on a single detection. Combine process creation, network connection, file creation, registry modification, DNS, process access, and injection indicators to build an attack timeline.

The same hunting approach can be reused across ransomware, Metasploit payloads, Mimikatz, RATs, backdoors, and command-and-control beacons:

1. Identify the suspicious event.
2. Pivot to the process that caused it.
3. Review parent process and command line.
4. Check related file, registry, network, and DNS activity.
5. Correlate by host, user, time, process ID, and rule name.

### Best Practices

| Practice | Meaning for SOC operations |
|---|---|
| Exclude > Include | Prefer excluding known-good activity instead of only including known-bad activity. This reduces the risk of missing novel threats while still cutting noise. |
| Use command-line filtering | `Get-WinEvent` and `wevtutil.exe` provide more precise filtering than the Event Viewer GUI. This matters when you need repeatable, narrow queries. |
| Know your environment | A rule is only useful if you understand what is normal for your hosts, users, applications, ports, and administrative tools. Baseline first, then tune. |

### Filtering Events with Event Viewer

Event Viewer provides basic filtering by Event ID and keywords. It can also filter with XML, but this approach is tedious and does not scale well for repeated hunting.

To open the filter menu, select **Filter Current Log** from the **Actions** menu.

![Filtering Events with Event Viewer](images/sysmon-101.png)

The filter menu allows analysts to select log scope, event IDs, keywords, and time ranges.

![Filtering Events with Event Viewer](images/sysmon-102.png)

Use Event Viewer for quick inspection, but use PowerShell when you need precise, repeatable hunting queries.

### Filtering Events with PowerShell

Use `Get-WinEvent` with XPath queries to filter Sysmon logs precisely. XPath filters can be built from the XML view of an event.

| Filter goal | XPath pattern |
|---|---|
| Filter by Event ID | `*/System/EventID=<ID>` |
| Filter by XML attribute/name | `*/EventData/Data[@Name="<XML Attribute/Name>"]` |
| Filter by event data value | `*/EventData/Data=<Data>` |

Example: find Sysmon network connections to destination port `4444`.

```powershell
Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=4444'
```

Example output:

```text
ProviderName: Microsoft-Windows-Sysmon

TimeCreated             Id  LevelDisplayName  Message
-----------             --  ----------------  -------
1/5/2021 2:21:32 AM      3  Information       Network connection detected:...
```

### Cutting out the Noise Questions



Read the above and practice filtering events.

#### How many event ID 3 events are in C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Filtering.evtx?

-Open the saved log and apply a filter. The number of filtered events appears just above the window

#### What is the UTC time of the first network event in the same logfile? Note that UTC time is shown only in the "Details" tab.

-UTC is only in the details of the event, not in the upper window

## Hunting Metasploit

[Metasploit-Event-File](assets/sysmon-task05.evtx)  

Metasploit is an exploit framework commonly used in penetration testing and red-team operations. From a SOC perspective, the concern is not just that Metasploit exists; the concern is that payloads often establish network callbacks and shells that can be detected through suspicious connection patterns.

Initial hunting pivots:

- Sysmon Event ID `3` for network connections.
- Suspicious destination ports such as `4444` and `5555`.
- Unknown or unexpected destination IP addresses.
- The process image associated with the connection.
- Packet captures or surrounding logs for deeper adversary context.

### Hunting Network Connections

Use a NetworkConnect rule to include suspicious back-connect ports.

```xml
<RuleGroup name="" groupRelation="or">
  <NetworkConnect onmatch="include">
    <DestinationPort condition="is">4444</DestinationPort>
    <DestinationPort condition="is">5555</DestinationPort>
  </NetworkConnect>
</RuleGroup>
```

Open the practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_Metasploit.evtx
```

A matching event provides important pivots such as `ProcessId` and `Image`.

![Hunting Network Connections](images/sysmon-103.png)

### Hunting for Open Ports with PowerShell

Use the same Event ID and `DestinationPort` logic from the Sysmon rule as an XPath filter.

```powershell
Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=4444'
```

Example:

```powershell
Get-WinEvent -Path C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_Metasploit.evtx -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=4444'
```

This query filters for:

1. Sysmon Event ID `3` (`NetworkConnect`).
2. Event data field named `DestinationPort`.
3. A destination port value of `4444`.

## Detecting Mimikatz

[Mimikatz-Event-File](assets/sysmon-task06.evtx)  

Mimikatz is commonly used to dump credentials from memory, especially by accessing LSASS. A SOC analyst should not rely only on filename detection because adversaries can rename, obfuscate, or stage the tool with droppers. Better detection uses behavior: file creation, elevated execution, remote thread creation, and abnormal access to `lsass.exe`.

Key hunting pivots:

- File creation containing `mimikatz`.
- Sysmon Event ID `10` where `TargetImage` is `lsass.exe`.
- Unexpected `SourceImage` accessing LSASS.
- Process creation and command line context around the access event.
- Parent process and user context.

### Detecting File Creation

Filename detection is simple but still useful when adversaries fail to rename or fully obfuscate the tool.

```xml
<RuleGroup name="" groupRelation="or">
  <FileCreate onmatch="include">
    <TargetFileName condition="contains">mimikatz</TargetFileName>
  </FileCreate>
</RuleGroup>
```

Use this as a low-effort catch, not as the primary detection strategy.

### Hunting Abnormal LSASS Behavior

Use `ProcessAccess` to detect access to LSASS. Access to `lsass.exe` by a process other than expected Windows processes should be treated as suspicious until explained.

```xml
<RuleGroup name="" groupRelation="or">
  <ProcessAccess onmatch="include">
    <TargetImage condition="image">lsass.exe</TargetImage>
  </ProcessAccess>
</RuleGroup>
```

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_LSASS.evtx
```

![Hunting Abnormal LSASS Behavior](images/sysmon-104.png)

If logs are noisy with `svchost.exe`, exclude that known-good source image and keep the LSASS include logic.

```xml
<RuleGroup name="" groupRelation="or">
  <ProcessAccess onmatch="exclude">
    <SourceImage condition="image">svchost.exe</SourceImage>
  </ProcessAccess>
  <ProcessAccess onmatch="include">
    <TargetImage condition="image">lsass.exe</TargetImage>
  </ProcessAccess>
</RuleGroup>
```

This narrows the event set so the analyst can focus on anomalous LSASS access.

### Detecting LSASS Behavior with PowerShell

```powershell
Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=10 and */EventData/Data[@Name="TargetImage"] and */EventData/Data="C:\Windows\system32\lsass.exe"'
```

Example:

```powershell
Get-WinEvent -Path C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_Mimikatz.evtx -FilterXPath '*/System/EventID=10 and */EventData/Data[@Name="TargetImage"] and */EventData/Data="C:\Windows\system32\lsass.exe"'
```

Example output:

```text
ProviderName: Microsoft-Windows-Sysmon

TimeCreated             Id  LevelDisplayName  Message
-----------             --  ----------------  -------
1/5/2021 3:22:52 AM     10  Information       Process accessed:...
```

## Hunting Malware

[Malware-Event-File](assets/sysmon-task07.evtx)  

This section focuses on RATs and backdoors. RATs often provide remote access, include anti-virus or detection evasion features, and commonly use a client-server model. Hunting begins by forming a hypothesis: identify the malware family, expected behavior, ports, process names, persistence methods, or network indicators, then tune Sysmon to expose that behavior.

### Hunting RATs and C2 Servers

The first hunting method is similar to Metasploit detection: identify suspicious network ports and correlate the connection to the process that made it. Known suspicious ports can help, but port-only detection is not enough. Always validate process, path, command line, parent process, user, destination, and timing.

Example Ion-Storm-style rule:

```xml
<RuleGroup name="" groupRelation="or">
  <NetworkConnect onmatch="include">
    <DestinationPort condition="is">1034</DestinationPort>
    <DestinationPort condition="is">1604</DestinationPort>
  </NetworkConnect>
  <NetworkConnect onmatch="exclude">
    <Image condition="image">OneDrive.exe</Image>
  </NetworkConnect>
</RuleGroup>
```

Caution: understand any exclusions before using a configuration in production. For example, excluding port `53` can hide malware that abuses DNS or uses port `53` for command-and-control.

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_Rats.evtx
```

The example detects a custom RAT using port `8080`, showing why analysts must avoid overly broad exclusions.

![Hunting RATs and C2 Servers](images/sysmon-105.png)

### Hunting for Common Back-Connect Ports with PowerShell

```powershell
Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=<Port>'
```

Example:

```powershell
Get-WinEvent -Path C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_Rats.evtx -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=8080'
```

Example output:

```text
ProviderName: Microsoft-Windows-Sysmon

TimeCreated             Id  LevelDisplayName  Message
-----------             --  ----------------  -------
1/5/2021 4:44:35 AM      3  Information       Network connection detected:...
1/5/2021 4:44:31 AM      3  Information       Network connection detected:...
1/5/2021 4:44:27 AM      3  Information       Network connection detected:...
1/5/2021 4:44:24 AM      3  Information       Network connection detected:...
1/5/2021 4:44:20 AM      3  Information       Network connection detected:...
```

## Hunting Persistence

[Persistence-Event-Files](assets/sysmon-task08.zip)  

Persistence is how attackers maintain access after compromise. Sysmon helps detect persistence by watching file creation and registry modification events. For rapid SOC triage, treat new files in startup locations and new registry autorun entries as high-value leads.

Primary persistence pivots:

- Event ID `11` for files created in startup or Start Menu locations.
- Event ID `12 / 13 / 14` for registry changes.
- Rule names such as `T1023`, `T1060`, or `RunKey` when available.
- File path, registry path, process image, parent process, and user context.

### Hunting Startup Persistence

SwiftOnSecurity-style rules can detect files placed in `\Startup\` or `\Start Menu` directories.

```xml
<RuleGroup name="" groupRelation="or">
  <FileCreate onmatch="include">
    <TargetFilename name="T1023" condition="contains">\Start Menu</TargetFilename>
    <TargetFilename name="T1165" condition="contains">\Startup\</TargetFilename>
  </FileCreate>
</RuleGroup>
```

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\T1023.evtx
```

The example shows `persist.exe` placed in the Startup folder. Attackers may use less obvious names, so any unauthorized change in startup locations should be investigated.

![Hunting Startup Persistence](images/sysmon-106.png)

Filtering by rule name, such as `T1023`, can reduce search time.

![Hunting Startup Persistence](images/sysmon-107.png)

The filtered result highlights relevant file creation events.

![Hunting Startup Persistence](images/sysmon-108.png)

After identifying a suspicious startup binary, investigate the directory, file hash, file owner, signer, creation time, parent process, and any associated network activity.

### Hunting Registry Key Persistence

Registry autorun locations are common persistence targets. The example below detects changes involving `CurrentVersion\Run`, Group Policy scripts, and related run-key paths.

```xml
<RuleGroup name="" groupRelation="or">
  <RegistryEvent onmatch="include">
    <TargetObject name="T1060,RunKey" condition="contains">CurrentVersion\Run</TargetObject>
    <TargetObject name="T1484" condition="contains">Group Policy\Scripts</TargetObject>
    <TargetObject name="T1060" condition="contains">CurrentVersion\Windows\Run</TargetObject>
  </RegistryEvent>
</RuleGroup>
```

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\T1060.evtx
```

The example shows `malicious.exe` added to:

```text
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\Persistence
```

The executable is located at:

```text
%windir%\System32\malicious.exe
```

![Hunting Registry Key Persistence](images/sysmon-109.png)

Use the rule name `T1060` to narrow the search. Then validate both the registry key and the file location.

![Hunting Registry Key Persistence](images/sysmon-110.png)

## Detecting Evasion Techniques

[Persistence-Event-File](assets/sysmon-task09.zip)  

Malware often uses evasion to avoid anti-virus, static detection, and basic analyst review. This section focuses on Alternate Data Streams and injection techniques.

Important evasion concepts:

- **Alternate Data Streams (ADS):** hides file content in NTFS streams separate from the normal `$DATA` stream.
- **Injection:** places malicious code into another process through techniques such as DLL injection, PE injection, thread hijacking, and process hollowing.
- **Masquerading / packing / obfuscation:** changes names, structure, or appearance to avoid detection or analyst recognition.

### Hunting Alternate Data Streams

Sysmon Event ID `15` hashes and logs NTFS streams included in the configuration. This helps detect hidden payloads that normal directory browsing may miss.

```xml
<RuleGroup name="" groupRelation="or">
  <FileCreateStreamHash onmatch="include">
    <TargetFilename condition="contains">Downloads</TargetFilename>
    <TargetFilename condition="contains">Temp\7z</TargetFilename>
    <TargetFilename condition="ends with">.hta</TargetFilename>
    <TargetFilename condition="ends with">.bat</TargetFilename>
  </FileCreateStreamHash>
</RuleGroup>
```

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Hunting_ADS.evtx
```

![Hunting Alternate Data Streams](images/sysmon-111.png)

Use `dir /r` to list alternate data streams from the command line.

```text
C:\Users\THM-Analyst\Downloads> dir /r
 Volume in drive C has no label.
 Volume Serial Number is C0C4-7EC1

 Directory of C:\Users\THM-Analyst\Downloads

01/19/2026  06:14 PM    <DIR>          .
01/19/2026  06:14 PM    <DIR>          ..
01/19/2026  06:14 PM           254,464 not_malicious.exe
                                    15 not_malicious.exe:malware:$DATA
01/05/2021  03:15 AM            53,351 sysmon-config-master.zip
                                   154 sysmon-config-master.zip:Zone.Identifier:$DATA
09/04/2025  09:31 PM        87,419,640 Wireshark-4.4.9-x64.exe
               3 File(s)     87,727,455 bytes
               2 Dir(s)  12,555,735,040 bytes free
```

The stream `not_malicious.exe:malware:$DATA` is the key anomaly. The base filename may look harmless, while the ADS contains hidden content.

### Detecting Remote Threads

Remote thread creation is used in evasion techniques such as DLL injection, thread hijacking, and process hollowing. The Windows API `CreateRemoteThread` can be legitimate, but it deserves scrutiny when the source and target process relationship is unusual.

Example rule that excludes common remote-thread noise:

```xml
<RuleGroup name="" groupRelation="or">
  <CreateRemoteThread onmatch="exclude">
    <SourceImage condition="is">C:\Windows\system32\svchost.exe</SourceImage>
    <TargetImage condition="is">C:\Program Files (x86)\Google\Chrome\Application\chrome.exe</TargetImage>
  </CreateRemoteThread>
</RuleGroup>
```

Practice log:

```text
C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Detecting_RemoteThreads.evtx
```

The example shows `powershell.exe` creating a remote thread and accessing `notepad.exe`, consistent with a process injection proof of concept. The specific technique shown is Reflective PE Injection.

![Detecting Remote Threads](images/sysmon-112.png)

### Detecting Evasion Techniques with PowerShell

For the provided rules, the Sysmon configuration already does most of the filtering. Query the Event ID directly and then review the event details.

Remote thread creation:

```powershell
Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=8'
```

Example:

```powershell
Get-WinEvent -Path C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Detecting_RemoteThreads.evtx -FilterXPath '*/System/EventID=8'
```

Example output:

```text
ProviderName: Microsoft-Windows-Sysmon

TimeCreated             Id  LevelDisplayName  Message
-----------             --  ----------------  -------
7/3/2019 8:39:30 PM      8  Information       CreateRemoteThread detected:...
7/3/2019 8:39:30 PM      8  Information       CreateRemoteThread detected:...
7/3/2019 8:39:30 PM      8  Information       CreateRemoteThread detected:...
7/3/2019 8:39:30 PM      8  Information       CreateRemoteThread detected:...
7/3/2019 8:39:30 PM      8  Information       CreateRemoteThread detected:...
```

## Practical Investigations

[Practical-Investigation-Files](assets/sysmon-task10.zip)  


### Investigation 1 - ugh, BILL THAT'S THE WRONG USB!

In this investigation, your team has received reports that a malicious file was dropped onto a host by a malicious USB. They have pulled the logs suspected and have tasked you with running the investigation for it.

Logs are located in Investigation-1.evtx.

### Investigation 2 - This isn't an HTML file? 

Another suspicious file has appeared in your logs and has managed to execute code masking itself as an HTML file, evading your anti-virus detections. Open the logs and investigate the suspicious file.  

Logs are located in Investigation-2.evtx.

### Investigation 3.1 - 3.2 - Where's the bouncer when you need him

Your team has informed you that the adversary has managed to set up persistence on your endpoints as they continue to move throughout your network. Find how the adversary managed to gain persistence using logs provided.

Logs are located in Investigation-3.1.evtx and Investigation-3.2.evtx.

### Investigation 4 - Mom look! I built a botnet!

As the adversary has gained a solid foothold onto your network it has been brought to your attention that they may have been able to set up C2 communications on some of the endpoints. Collect the logs and continue your investigation.

Logs are located in Investigation-4.evtx.

### Investigation Questions  

#### What is the full registry key of the USB device calling svchost.exe in Investigation 1? 

-1. Used "find" to search for USB. The first entry indicated EventID 13
-2. Filter for EventID 13; Results in only two entries. "Task Category" includes "Registry value", so could have easily searched for that. Conclusion is that EventID 13 is registry value settting
-3. Answer is in the second of the two packets. Not sure why
-A: HKLM\System\CurrentControlSet\Enum\WpdBusEnumRoot\UMB\2&37c186b&0&STORAGE#VOLUME#_??_USBSTOR#DISK&VEN_SANDISK&PROD_U3_CRUZER_MICRO&REV_8.01#4054910EF19005B3&0#\FriendlyName

#### What is the device name when being called by RawAccessRead in Investigation 1?

-1. Clear previous filters
-2. Observe that "RawAccessRead" appears with EventID 9, so filter for that.
-Answer appears in the "Event Data" area under XML View: \Device\HarddiskVolume3

#### What is the first exe the process executes in Investigation 1?

-Checked out the first entry, which creates a process. Thought answer might be WUDFHost.exe. That was wrong. Creating the process is not the first exe the process executes.
-Decided to jump down to another "Process Create" which executed "rundll32.exe"
-Answer: rundll32.exe

#### What is the full path of the payload in Investigation 2?

-Only three entries in the log. Decided to observer the third entry first
-Answer: C:\Users\IEUser\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5\S97WTYG7\update.hta

#### What is the full path of the file the payload masked itself as in Investigation 2?

-Appears in the same event
-Answer: C:\Users\IEUser\Downloads\update.html

#### What signed binary executed the payload in Investigation 2?

-answer makes sense because this binary executes content in the Temporary intenet files folder
-Answer: C:\Windows\System32\mshta.exe

#### What is the IP of the adversary in Investigation 2?

-In the second packet, but this the host reaching out to the adversary
-Answer: 10.0.2.18

#### What back connect port is used in Investigation 2?

-Answer: 4443

#### What is the IP of the suspected adversary in Investigation 3.1?

-EventID 3 indicates the host is reaching out to the internet (adversary in this case)
-the first EventID 3 line holds the answer in the "DestinationIp"
-Answer: 172.30.1.253

#### What is the hostname of the affected endpoint in Investigation 3.1?

-Answer: DESKTOP-O153T4R

#### What is the hostname of the C2 server connecting to the endpoint in Investigation 3.1?

-Answer: empirec2

#### Where in the registry was the payload stored in Investigation 3.1?

-Stored in EventID 13
-First instance of the event ID
-Answer: HKLM\SOFTWARE\Microsoft\Network\debug

#### What PowerShell launch code was used to launch the payload in Investigation 3.1?

-Needed to include the quotes because the quotes are the data
-Answer: "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -c "$x=$((gp HKLM:Software\Microsoft\Network debug).debug);start -Win Hidden -A \"-enc $x\" powershell";exit;

#### What is the IP of the adversary in Investigation 3.2?

-First network connection log entry; EventID 3
-Answer: 172.168.103.188

#### What is the full path of the payload location in Investigation 3.2?

-Answer: c:\users\q\AppData:blah.txt
-The payload was stored in the target as a redirect of an echo command.

#### What was the full command used to create the scheduled task in Investigation 3.2?

-EventID 1
-Event Record: 27752
-Answer: C:\WINDOWS\system32\schtasks.exe" /Create /F /SC DAILY /ST 09:00 /TN Updater /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonI -W hidden -c \"IEX ([Text.Encoding]::UNICODE.GetString([Convert]::FromBase64String($(cmd /c ''more < c:\users\q\AppData:blah.txt'''))))\""

#### What process was accessed by schtasks.exe that would be considered suspicious behavior in Investigation 3.2?

-EventID 10 is a process accessed
-Answer: lsass.exe

#### What is the IP of the adversary in Investigation 4?

-Answer: 172.30.1.253

#### What port is the adversary operating on in Investigation 4?

-Answer: 80

#### What C2 is the adversary utilizing in Investigation 4?

-Answer: empire
-'empirec2' appears in every record. Finally just tried inputting the answer without the "c2"