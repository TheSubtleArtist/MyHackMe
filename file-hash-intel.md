# File and Hash Threat Intelligence

It's Monday in April. Try Daily is preparing and significant release. The EDR tools flags multiple binaries on various workstations during a routine Alert Sweep. You, the L1 analyst recevies a curated triage package containing those samples. Within 60 minutes you must provide evidence to showcase whether these files are bait, benign, or malicous.

## Filenames and Paths

Human-readable strings are the most basic heuristics available.
- unlikely to reveal malicousness
- can reveal tradecraft pattterns 

### Filepath Analysis

`C:\` (System Drive); common target for persistence mechanisms  
`C:\Users\Public` enables cross-user access of detonated addversary tools  
`C:\Users\Public\Public Downloads` privdes high-traffic directory which can evade strict moniotring.
`C:\Windows\Temp` or other temp directories for ephemeral payloads  
`C:\ProgramData\` these writeable system paths allow for stealth persistence  

### Filename Heuristic indicators

Common tactice to modify filenames to escapt detection

- double extensions (`invoice.pdf.exe`) leverage default settings that hide malicious file extensions
- System binary impersonation: abuse of filenames (`scvhost.exe`) to abuse user abuse of core system process familiarity.  Defndes include legitimate locations for system processes in an allowlist rather than standalong filenames
- High-entropy strings: non-sensicale filenames (`jh8F21.exe`) suggest packing or polymorphic generation, commonly used in high-churn phishing oepration.
- Masquerading: filenames (`backup-2300.exe`) blend with routene files; leeverage reduced suspicious. Single character substitution bypasses detection while looking visually legitmate to an unsuspecting employee.  

### Filesnames and Paths Quetions  

One of the files included in the CTI Files folder on the Desktop shows one of the indicators mentioned. Can you identify the file and the indicator? (Answer: file, property)  

double extensions.

## File Hash Lookup

File hashes uniquely identify files and malware, regardless of name changes.
- store hashes in lowercase to avoide needless differences
- hash what matters in the investigation (e.g. the malicious binary extracted from an archive and the original archive)  
- do not leave plain strings ithout the context of where and when you encoutered them
- Any byte change wil change a resulting hash

### Analysis with VirusTotal

- Detection Socre: represents a crowdsourced security verdict from various vendors displayed as a ration; higher numbers indicate higher confidence  
- Threat lables and categories: vendor-specfiic classifications of threat; help to confirm attribution across vendors  
- Detection rules: technical signatures used by AV engines to identify threats. Typical classifications are YARA rules, Heuristic patterns, and behaviorsal triggers
- Properties: where core metadata for hte fiel is stored, including fiel type, size, and compilation timestamp
- Contained domains and IPS: malware's network infrstructure
- Contained files: files embedded or dropped during the malware's execution

| Section                               | Key Question                                     | Red Flags                                                                                                                                 | Analyst Considerations                                                                                                                                                 |
| ------------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Detection Score and Threat Labels** | How many vendors detect this file as malicious?  | - Five or more solid vendors flag it<br>- Conflicting classifications (e.g., “Trojan” vs “PUA”)<br>- No consensus among the top 3 vendors | - New malware often has low initial detection<br>- Recheck after 24h for updated results<br>- Look at the classification of the malware family name or capability name |
| **Upload Time**                       | When was the file first submitted?               | - Uploaded seven days ago with more than 10 detections<br>- Sudden detection spike after days/weeks                                       | - Vendors need 48–72 hours for full analysis<br>- Historical detection growth indicates malware ageing                                                                 |
| **Signatures**                        | Is the file properly signed?                     | - Invalid/missing certificate<br>- Certificate issued to an unrelated entity                                                              | - Even valid certs can be stolen/abused<br>- Check cert chain expiration dates                                                                                         |
| **Properties**                        | Are there anomalies in the file data?            | - Compile timestamp at odd hours (e.g., 3 AM)<br>- High entropy (>7.5) in non-media files                                                 | - Some legitimate packers (UPX) increase entropy<br>- Compare with known-good versions                                                                                 |
| **Relations**                         | What infrastructure does the malware connect to? | - Known-bad IPs in VirusTotal’s graph<br>- DGA-like domains (e.g., `xk8f92.xyz`)                                                          | - Legitimate CDNs may host malware<br>- Check IPs in Shodan for open ports                                                                                             |
| **Behavioral**                        | What post-execution actions occur?               | - Modifies critical registry keys<br>- Attempts process injection                                                                         | - Some admin tools modify registries legitimately<br>- Correlate with endpoint logs                                                                                    |

### Cross-Reference with Malware Bazaar  

All-in-on database for malware collection and analysis

- Malware Sampels Upload: upload malware samples for analysis and build the intelligence database.
- Malware Hunting: hunting for malware samples through various elements  
  - Malware Family tagging: files calssified by malware families rather than simple confidence levels
  - YARA rule integration: inclusion of rules that detected related samples
  - Campaign attribution: Tags that include threat actor groups
  - Sample Availability: samples available for download and re-analysis


### File Hash Lookup Questions

What is the SHA256 hash of the file bl0gger?  

`:> get-filehash -Algorithm SHA256`  

Rest of answers are from trydetectthis.thml:8080:  

What is the threat classification label used to identify the malicious file?  

When was the file first submitted for analysis? (Answer format: YYYY-MM-DD HH:MM:SS)

Which vendor classified the Morse-Code-Analyzer file as non-malicious?

What MITRE technique has been flagged for persistence and privilege escalation for the Morse-Code-Analyzer file?


## Sandbox Analysis

### Dynamic Analysis for SOC

- Cofirm execution - if nothing happens, the alert could be a decoy.
- Extract runtime IOCs - domains, mutexes, dropped payloads, feed hunts and detections
- Map to ATT&CK - most sandboxes auto-lable behavior with technique IDs, fast-trackign reports

### Sandboxing Tools

#### Hybrid Analysis  

Focuses on behavior trees and a clean MITRE ATT&CK heatmap.  
Suitabel for fast executive summary  

Searching by file hash can confirm a feil is malicious  
additional information inclue risk behavior and ATT&CK Techniques.  

[hybrid-analsys](assets/file-hash-intel-101.png)  

#### Joe Sandbox

Deep analysis.  
Covering system calls, strings, and memory dumps.  
Great for reverse engineers and detection engineers

### Sandboxing Limitations

1. Sanbox Evastion Techniques: threat actors design payloads to detect and evade sandboxes, leading to false negatives
   1. Environment Awareness Checks that reduce behavior if a sandbox is detected
   2. Anti-dubggin and Anti-sandboxing tracks that look for unique hardware IDs
2. Limited Execution Time and coverage: Sandboces maight terminate anlaysis after short period of time; leaves multi-stage malware unexecuted; time delay attacks avoid detection
3. Encrypted and Obfuscated Traffic
4. Fileless & Living-off-the-land Malware


### Sandbox Analysis Questions

What tags are used to identify the bl0gger.exe malicious file on Hybrid Analysis? (Answer: Tag1, Tag2, Tag3)  

Move to the Internet website, not the VM  

Easily identified by the '#'

What was the stealth command line executed from the file?

Which other process was spawned according to the process tree?

Analyze the payroll.pdf file located in the CTI Files folder and answer the questions below. The payroll.pdf application seems to be masquerading as which known Windows file?

What associated URL is linked to the file?

How many extracted strings were identified from the sandbox analysis of the file?


## Threat Intelligence Challenge

What is the SHA256 hash of the file?

What family labels are assigned to the file on VirusTotal?

When was the first time the file was recorded in the wild? (Answer Format: YYYY-MM-DD HH:MM:SS UTC)

Name the text file dropped during the execution of the malicious file.

What PowerShell command is observed to be executed?

What MITRE ATT&CK ID is associated with the actions of the command?
