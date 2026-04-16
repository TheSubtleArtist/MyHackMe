# Data Exfiltration Detection

## Data Exfil: Overview, Techniques, and Indicators

### Why Adversaries Perform Data Exfiltraiton

### Threat Actors & Their Techniques 

| Threat Actor / Campaign        | Exfiltration Technique                  | Description                                                                 |
|------------------------------|------------------------------------------|-----------------------------------------------------------------------------|
| APT29 (Cozy Bear)            | HTTPS over legitimate domains            | Used encrypted HTTPS channels over trusted domains to exfiltrate sensitive data from government networks. |
| FIN7                         | HTTP POST requests to command-and-control (C2) servers | Embedded stolen data within HTTP POST requests to evade network-based detection controls. |
| Lunar Spider (Zloader)       | Encrypted C2 channels with staged exfiltration | Maintained long-term intrusion (approx. two months) using encrypted channels and staged data exfiltration techniques. |
| DarkSide Ransomware          | Dual extortion (data exfiltration + encryption) | Exfiltrated sensitive data prior to encrypting systems, leveraging threat of public data leaks for additional pressure. |
| APT10 (Cloud Hopper)         | Cloud-to-cloud transfer via APIs         | Leveraged cloud service APIs to exfiltrate data from managed service providers across cloud environments. |

### Common Exfiltration Phases


| Phase | Objective | Description | Common Techniques | Example Indicators | Defensive Considerations |
|------|----------|-------------|-------------------|--------------------|--------------------------|
| Discovery / Collection | Identify and gather sensitive data | The attacker locates and collects data of interest from local systems, network shares, databases, or cloud resources. This may include intellectual property, credentials, financial data, or operational documents. | File system enumeration, database queries, memory scraping, API enumeration, credential harvesting | Unusual file access patterns, access to large numbers of sensitive files, privilege escalation preceding access | Implement least privilege access, monitor file access patterns, enable data classification and DLP policies |
| Staging / Preparation | Aggregate and prepare data for exfiltration | The attacker consolidates collected data into centralized locations and prepares it for efficient transfer. Preparation may include compression, encryption, encoding, or obfuscation to evade detection. | Compression (ZIP, RAR, 7z, tar), encryption (AES, custom), encoding (Base64), steganography, file splitting | Creation of large archive files, use of compression tools in unusual contexts, temporary staging directories | Monitor for abnormal archive creation, restrict unauthorized tooling, inspect file entropy and anomalies |
| Exfiltration Transport | Transfer data outside the environment | The attacker moves data from the compromised environment to an external destination. This can occur over network channels, physical media, or cloud services, often using covert or disguised methods. | HTTPS, DNS tunneling, FTP/SFTP, cloud storage uploads, removable media (USB), covert channels | Large outbound data transfers, unusual destinations, abnormal DNS queries, data transfer outside business hours | Enforce egress filtering, monitor outbound traffic, use DLP solutions, restrict removable media usage |
| Command & Control (C2) Coordination | Orchestrate and verify exfiltration | The attacker uses command-and-control infrastructure to manage the exfiltration process, including initiating transfers, adjusting techniques, and confirming successful receipt of data. | Beaconing to C2 servers, tasking via encrypted channels, API-based control, callback confirmations | Regular beaconing patterns, connections to known malicious infrastructure, encrypted traffic to unknown endpoints | Detect and block C2 traffic, use threat intelligence feeds, analyze beaconing behavior, implement network segmentation |
| Cleanup / Anti-Forensics (Optional but Common) | Remove evidence and maintain persistence | After exfiltration, attackers may delete logs, remove tools, or alter artifacts to avoid detection and enable future access. | Log deletion, timestomping, file wiping, disabling security tools | Missing logs, altered timestamps, disabled monitoring agents | Enable centralized logging, protect logs from modification, use integrity monitoring tools |

### Techniques and Indicators

| Technique Category | Examples | Indicators of Attack & Where to Look |
|---|---|---|
| Network-based exfiltration | HTTP/HTTPS uploads to web applications, Azure Blob Storage, or webmail; SFTP/SCP transfers; DNS tunneling; ICMP or other covert protocol abuse; custom command-and-control exfiltration channels | Web gateway logs for large POST requests, file uploads, and traffic to cloud storage endpoints; NGFW or firewall flow logs for high outbound byte counts to a single IP, domain, or ASN; NetFlow/sFlow for spikes in outbound flows; DNS logs for long hostnames, high query volume, or unusual TXT record lookups |
| Host-based exfiltration activity | PowerShell `Invoke-WebRequest`; `rclone`; `awscli`; `curl` / `wget`; archive creation with ZIP/RAR/7z/tar; use of removable USB media; NTFS alternate data streams (ADS) or other hidden streams | Endpoint Detection and Response (EDR) telemetry for Process Create, Network Connect, and File Create events; Windows Security logs such as Event IDs 4663 and 4656 for object access; Linux `auditd` logs and shell history on endpoints and servers; removable media monitoring logs and device control events |
| Cloud exfiltration | Amazon S3 `PutObject` and multipart uploads; Azure Blob Storage uploads; Google Cloud Storage object uploads; Google Drive / Microsoft SharePoint external sharing; other SaaS-based file transfer or synchronization | AWS CloudTrail, Azure Activity Logs, and GCP Audit Logs; cloud storage access logs; SaaS audit logs for file sharing and downloads; unusual service account behavior, anomalous IP addresses, impossible travel, or unexpected data movement patterns |
| Covert channels & encoding | DNS tunneling; Base64 or chunked encoding; steganography in image or audio files; splitting files into many small requests for low-and-slow exfiltration | DNS logs for anomalous query structures and volume; proxy or web logs showing many small POST requests; packet capture or network telemetry revealing unusual encoding patterns; correlation of intermittent uploads with suspicious endpoint process activity |
| Insider misuse & collaboration tools | Slack, Microsoft Teams, Dropbox, Google Drive, Box, or similar platforms used to upload or share data externally; compromised employee accounts abusing legitimate collaboration channels | SaaS audit logs for external share events, mass file downloads, and permission changes; identity provider logs for suspicious sign-ins; email and mail gateway logs for forwarding activity or outbound file sharing notifications |
| General indicators of attack (IoAs) & triage signals | Large outbound data volume to external IPs or domains; unknown destination domains; suspicious processes or command lines; many file read events followed by outbound network connections; multipart or streamed uploads | Correlate EDR, firewall, proxy, DNS, cloud audit, and SIEM data; review Sysmon logs, especially Event IDs 1, 3, and 11; inspect mail server logs; investigate timelines that show file access, archive creation, process execution, and network transfer occurring in sequence |

## Detection: Data Exfil through DNS Tunneling

### DNS Tunneling

- DNS queries are nomrally allowed through firewalls and gateways, creating attraictve covert channel
- Uses UDP for queriees and responses
- Uses TCP for zone transfers or large transfers
- "Always-on" service
- Queries always look normal, until inpsected closesly
- data can be easily encoded into the subdomain labels or txt responses

### Indicators of Attack

- High numbers of DNS quries sent to a single external domain, creating large deviation from a baseline  
- long subdomain labels or query names
- high entropy, base32, base64 in query names
- Rare record types (txt, null) or many large txt responses
- frequent NXDOMAIN if attacker uses exfil-by-query without providng an answer. NXDOMAIN is a DNS response code indicating that the queried domain name does not exist  
- TCP or large UDP framents used for DNS
- Queries at regular intervals indicate beaconing behavior

## Detection: Data Exfil through FTP

### How adversaries use FTP for exfiltration

- use of legitimate FTP servers to stage / transfer data  
- use of compromised credentaisl for service accounts or users  
- Use of non-standard ports or tunneling to blend in with other traffic

### Indicators of attack

- appearance of USER and PASS commands in cleartext  
- STOR and RET commands used for repeated or large transfers  
- Large data connections to unusual external IPs
- FTP transactions outside normal business hours  
- Opening of data channels on ephermeal ports (PASV) paired with large payloads  
  
## Detection: Data Exfil via HTTP

### Data exfiltration via HTTP/HTTPS

Data exfiltration via **HTTP/HTTPS** is when an attacker moves sensitive data out of a target network using **web protocols** as the transport. **HTTP/HTTPS** is commonly abused because it blends with normal web traffic, can traverse firewalls and proxies, and can be obfuscated through **encoding, encryption, and tunneling**. This detection task aims to teach analysts how to identify signs of **HTTP/HTTPS-based** exfiltration in packet captures (**Wireshark**) and logs (**Splunk**), and to provide practical search queries and investigation steps.

### Why it matters

- **HTTP/HTTPS-based exfiltration** is very common; attackers hide exfiltration in the noise of legitimate web usage.
- Successful detection stops data breaches and helps trace attacker activity post-compromise.
- Organizations must detect and respond to protect sensitive data and meet compliance requirements.

### How adversaries use HTTP/HTTPS for data exfiltration

| How adversaries use HTTP/HTTPS for data exfiltration | Description |
|---|---|
| POST uploads to external servers | Bulk data is sent to attacker-controlled hosts or cloud storage in HTTP POST request bodies. |
| GET requests with encoded data | Attackers place small chunks of encoded data into query strings or path segments, useful for low-and-slow exfiltration. |
| Use of common services / CDN | Exfiltration is disguised as uploads to popular services, content delivery networks, or attacker-controlled subdomains hosted under reputable domains. |
| Custom headers | Data placed in HTTP headers, such as `X-Data: <base64>`, may bypass some string-based DLP controls. |
| Chunked transfer / multipart | Large payloads are split across multiple HTTP requests to avoid size thresholds or simplistic alerting logic. |
| HTTPS/TLS tunneling | The encrypted channel hides payload contents; detection relies on TLS inspection, SNI analysis, certificate review, and metadata-based detection. |
| Staging via cloud services | The attacker uploads data to services such as Dropbox, GitHub, or Gist and later retrieves it externally. |

Adversaries adapt by using low-and-slow approaches, encryption and encoding, and legitimate services to evade detection.

### Indicators of Attack (IoAs)

| Indicator of Attack (IoA) Category | Details |
|---|---|
| Unusually large HTTP POST requests | Large outbound POST bodies sent to external or unexpected hosts may indicate bulk data transfer. |
| Requests to low-reputation or rare domains | HTTP requests to domains with poor reputation or rarely seen in baseline traffic may indicate suspicious destinations. |
| Frequent small requests followed by large uploads | Repeated small requests to the same host, followed by a larger transfer, may indicate beaconing and staged exfiltration. |
| Chunked or multipart transfers | Multiple related requests that together compose a larger file transfer may indicate attempts to evade volume-based detection. |

### Common network indicators

| Common network indicator | What to look for |
|---|---|
| Large outbound POST traffic | Review HTTP logs, proxy logs, or full packet capture for abnormally large POST requests leaving the environment. |
| Unexpected external destinations | Identify outbound traffic to hosts, domains, or IPs that are unusual for the system or user. |
| Repeated small connections | Look for recurring low-volume requests to the same destination, especially when paired with later upload activity. |
| Multipart or chunked uploads | Examine whether multiple HTTP requests appear to reconstruct a single larger transfer. |


## Detection: Data Exfiltration via ICMP

```markdown id="icmp-exfil-summary"
## ICMP is a network-layer protocol used for diagnostics and control (e.g., ping, time exceeded)

- **Protocol:** ICMP (Internet Control Message Protocol)
- **Layer:** Network Layer (Layer 3)
- **Legitimate Uses:**
  - Connectivity testing (`ping`)
  - Path analysis (`traceroute`)
  - Error reporting (destination unreachable, time exceeded)

### Why ICMP is abused

| Characteristic | Security Impact |
|---|---|
| Commonly allowed through firewalls | Provides an open channel for outbound communication |
| Often lightly inspected | Lower visibility compared to HTTP/HTTPS traffic |
| Flexible payload structure | Can carry arbitrary data |
| Stateless behavior | Harder to track session-based anomalies |

---

### How attackers abuse ICMP

| Technique | Description | Notes |
|---|---|---|
| ICMP echo (Type 8) / reply (Type 0) tunneling | Encoded data (Base64, hex) embedded in payloads and transmitted to attacker-controlled systems | Most common method |
| Custom ICMP types/codes | Use of uncommon types or non-standard codes to evade detection signatures | Often overlooked in monitoring |
| Fragmentation & reassembly | Large data split across multiple packets and reassembled by receiver | Helps bypass size-based detection |
| Encoding / encryption | Data encoded (Base64, hex) or encrypted to appear random | Increases entropy, reduces detectability |
| Covert channel tunneling | Continuous bidirectional communication using ICMP as a transport layer | Mimics legitimate diagnostic traffic |

---

## How adversaries use ICMP for exfiltration

### Common techniques

- **Data Encoding**
  - Base64 (most common)
  - Hex encoding
  - Custom encoding schemes

- **Transport Patterns**
  - Continuous echo request/reply sequences
  - Low-and-slow periodic transmission
  - Burst-based exfiltration

- **Payload Handling**
  - Chunking data into small segments
  - Reassembly on remote listener
  - Optional encryption before encoding

---

## Indicators that something may be malicious

| Indicator | What it Suggests |
|---|---|
| Persistent ICMP communication to external host | Possible covert channel or data exfiltration |
| Large ICMP payload sizes (> typical ping size ~32–64 bytes) | Data being embedded in payload |
| High-entropy payloads | Encoded or encrypted content |
| Repetitive or patterned payload structures | Chunked data transmission |
| ICMP activity without corresponding application traffic | Suspicious standalone communication channel |
| ICMP traffic to unusual or untrusted destinations | Potential attacker-controlled endpoint |

---

## Indicators of attack in Wireshark

### Look for the following in a packet capture (PCAP) when inspecting in Wireshark:

| Indicator | Wireshark Field / Filter | What to Look For |
|---|---|---|
| High ICMP packet volume | `icmp` | One host sending many ICMP packets to a single external IP |
| Large payload size | `frame.len`, `icmp.data` | Payloads significantly larger than normal (e.g., >64 bytes) |
| Unusual ICMP types/codes | `icmp.type`, `icmp.code` | Use of uncommon types such as timestamp (13/14) or non-standard codes |
| Regular timing / periodicity | Time delta analysis | Evenly spaced packets indicating automated transmission |
| Fragmentation & reassembly | `ip.flags.mf == 1` or reassembled streams | Multiple fragments forming larger payloads |
| High entropy payloads | Byte analysis / hex view | Random-looking data indicative of encoding/encryption |

---

### Quick Analyst Checklist

- [ ] Identify **source host** generating ICMP traffic  
- [ ] Validate **destination IP/domain reputation**  
- [ ] Check **payload size and frequency patterns**  
- [ ] Inspect **payload content (hex/ASCII view)**  
- [ ] Correlate with **endpoint activity (processes, file access)**  
- [ ] Confirm whether ICMP usage aligns with **legitimate operational needs**

---

