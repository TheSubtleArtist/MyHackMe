# Brim

## What is Brim?

Brim is an open-source desktop application for processing packet captures and structured log files. Its primary value is search, analytics, and event correlation for network investigation workflows.

Key points:

- Brim processes packet capture data and presents the results in a searchable interface.
- Brim uses Zeek log processing format and can work with Zeek-generated logs.
- Brim supports Zeek signatures and Suricata rules for detection.
- Brim helps analysts move from raw packet data toward higher-level investigation artifacts.

Brim can ingest two main data types:

- **Packet capture files:** PCAP files created with tools such as `tcpdump`, `tshark`, and Wireshark.
- **Log files:** Structured log files such as Zeek logs.

Brim is built on several open-source components:

- **Zeek:** Log-generating engine.
- **Zed Language:** Log querying language that supports keyword searches, filters, and pipelines.
- **ZNG Data Format:** Data storage format that supports saving data streams.
- **Electron and React:** Cross-platform user interface technologies.

## Why Brim?

Large packet captures can become difficult to investigate directly in Wireshark. PCAP files larger than one gigabyte are often cumbersome to load, search, and review interactively.

Brim reduces investigation time by:

- Processing larger PCAPs into searchable log data.
- Providing a GUI for reviewing Zeek-style logs.
- Supporting correlation between related events and streams.
- Helping analysts pivot quickly between connection records, DNS activity, HTTP activity, file activity, and alert data.

## Brim vs. Wireshark vs. Zeek

Each tool has a different operational strength. The usual workflow is:

- Use **Wireshark** for packet-level inspection and medium-sized captures.
- Use **Zeek** to generate logs and correlate network events.
- Use **Brim** to process and investigate multiple logs through a GUI.

| Capability | Brim | Wireshark | Zeek |
|---|---|---|---|
| Purpose | PCAP processing; event, stream, and log investigation | Traffic sniffing; PCAP processing; packet and stream investigation | PCAP processing; event, stream, and log investigation |
| GUI | Yes | Yes | No |
| Sniffing | No | Yes | Yes |
| PCAP processing | Yes | Yes | Yes |
| Log processing | Yes | No | Yes |
| Packet decoding | No | Yes | Yes |
| Filtering | Yes | Yes | Yes |
| Scripting | No | No | Yes |
| Signature support | Yes | No | Yes |
| Statistics | Yes | Yes | Yes |
| File extraction | No | Yes | Yes |
| Handling PCAPs over 1 GB | Medium performance | Low performance | Good performance |
| Ease of management | 4/5 | 4/5 | 3/5 |

Source: TryHackMe Brim room.

## The Basics

### Landing Page

The Brim landing page provides a file import window and three main areas:

- **Pools:** Imported data resources, such as investigated PCAP and log files.
- **Queries:** Saved or available queries.
- **History:** Previously executed queries.

### Pools and Log Details

Pools represent imported files. When a PCAP is loaded, Brim processes it, creates Zeek logs, correlates them, and displays findings in a timeline.

![Pools and Log Details](/images/brim-101.png)

The timeline helps identify the capture start and end dates. Brim also provides field details. Hovering over fields, such as Zeek `conn.log` or `uid`, helps identify field meaning and supports custom query creation.

The right pane provides additional log field details, and the export function near the timeline can be used to export results.

![Pools and Log Details](/images/brim-102.png)

Log entries can be correlated using the correlation section in the log details pane. This view helps answer the operational question: **Where should I look next?**

Correlation details can include:

- Source address.
- Destination address.
- Duration.
- Associated log files.
- Related evidence for the event of interest.

Right-clicking a field supports common investigation actions:

- Filter values.
- Count fields.
- Sort values A-Z or Z-A.
- View details.
- Perform a WHOIS lookup on an IP address.
- View associated packets in Wireshark.

![Pools and Log Details](/images/brim-103.png)

### Queries and History

Queries are used to correlate findings and locate events of interest. History records the queries that have already been executed.

![Queries and History](/images/brim-104.png)

The query library supports reusable investigation workflows:

- Queries can have names, tags, and descriptions.
- Double-clicking a query places the actual query in the search bar.
- Executed queries are listed in the history tab.
- Results appear under the search bar.
- New queries can be added with the `+` button near the Queries menu.

![Queries and History](/images/brim-105.png)

Brim includes 12 premade queries under the **Brim** folder. These are useful templates for learning query structure and performing quick searches.

## Default Queries

Open Brim, import the sample PCAP, and use the default queries to understand available data sources and common investigation pivots.

![Default Queries](/images/brim-106.png)

### Reviewing Overall Activity

This query provides general information about the PCAP file. It is useful because advanced or case-specific queries depend on knowing which log files are available. In the sample, Brim generated 20 log types from the PCAP.

### Windows Specific Networking Activity

This query focuses on Windows networking activity and shows fields such as:

- Source address.
- Destination address.
- Named pipe details.
- Endpoint details.
- Operation detection.

This is useful for investigating SMB enumeration, login activity, and service exploitation.

![Windows Specific Networking Activity](/images/brim-107.png)

### Unique Network Connections and Transferred Data

These queries help identify unique connections and summarize connection data.

Operational use:

- Detect unusual or malicious connections.
- Identify suspicious beaconing activity.
- Review unique communication pairs.
- Compare data transfer volume to support anomaly hypotheses.

![Unique Network Connections and Transferred Data](/images/brim-108.png)

### DNS and HTTP Methods

DNS and HTTP method queries list observed DNS queries and HTTP methods.

Operational use:

- Detect anomalous DNS traffic.
- Identify suspicious domains.
- Review HTTP methods such as `POST` and `GET`.
- Narrow web activity by modifying default HTTP queries.

![DNS and HTTP Methods](/images/brim-109.png)

### File Activity

The file activity query lists detected files. It can help identify:

- Possible data leakage.
- Suspicious file movement.
- Malware download or transfer.
- MIME type, filename, and hash values such as MD5 and SHA1.

![File Activity](/images/brim-110.png)

### IP Subnet Statistics

This query lists available IP subnets. It helps analysts detect communication outside expected scope and identify unusual network destinations.

![IP Subnet Statistics](/images/brim-111.png)

### Suricata Alerts

Suricata alert queries provide rule-based detection results in multiple formats:

- Category-based.
- Source and destination based.
- Subnet based.

Suricata is an open-source threat detection engine that can operate as a rule-based intrusion detection and prevention system. It is developed by the Open Information Security Foundation and detects anomalies similarly to Snort, including support for similar signatures.

![Suricata Alerts](/images/brim-112.png)

## Use Cases

### Custom Queries and Use Cases

Traffic analysis requires identifying common patterns and indicators of anomalous or malicious traffic. Brim queries are most effective when they use explicit field filters rather than blind keyword searches.

### Brim Query Reference

| Purpose | Syntax | Example |
|---|---|---|
| Basic search | Search any string or numeric value | `10.0.0.1` |
| Logical operators | `or`, `and`, `not` | `192 and NTP` |
| Filter values | `field_name == value` | `id.orig_h==192.168.121.40` |
| List specific log contents | `_path=="log name"` | `_path=="conn"` |
| Count field values | `count() by field` | `count() by _path` |
| Sort findings | `sort` | `count() by _path | sort -r` |
| Cut a specific field | `_path=="conn" | cut field_name` | `_path=="conn" | cut id.orig_h, id.resp_p, id.resp_h` |
| List unique values | `uniq` | `_path=="conn" | cut id.orig_h, id.resp_p, id.resp_h | sort | uniq` |

Best practice:

- Use field names and filtering options.
- Avoid relying on irregular or blind search queries.
- Use Brim indexing intentionally by filtering on known fields and log paths.

### Common Brim Investigation Queries

#### Communicated Hosts

Identifies hosts actively communicating on the network. This is a first step for detecting access violations, exploitation attempts, and malware infections.

```zed
_path=="conn" | cut id.orig_h, id.resp_h | sort | uniq
```

#### Frequently Communicated Hosts

Shows which hosts communicate most frequently, supporting analysis of data exfiltration, exploitation, and backdoor activity.

```zed
_path=="conn" | cut id.orig_h, id.resp_h | sort | uniq -c | sort -r
```

#### Most Active Ports

Helps identify hidden or unusual services by focusing on destination ports and service labels.

```zed
_path=="conn" | cut id.resp_p, service | sort | uniq -c | sort -r count
```

```zed
_path=="conn" | cut id.orig_h, id.resp_h, id.resp_p, service | sort id.resp_p | uniq -c | sort -r
```

#### Long Connections

Long-lived connections can indicate anomalies such as backdoors, especially when the client should not maintain continuous sessions.

```zed
_path=="conn" | cut id.orig_h, id.resp_p, id.resp_h, duration | sort -r duration
```

#### Transferred Data

Large transfer volumes can support data exfiltration or suspicious file transfer hypotheses.

```zed
_path=="conn" | put total_bytes := orig_bytes + resp_bytes | sort -r total_bytes | cut uid, id, orig_bytes, resp_bytes, total_bytes
```

#### DNS and HTTP Queries

Suspicious domains and HTTP requests can reveal C2 channels and compromised hosts.

```zed
_path=="dns" | count() by query | sort -r
```

```zed
_path=="http" | count() by uri | sort -r
```

#### Suspicious Hostnames

DHCP logs can reveal hostnames and domains useful for finding rogue hosts.

```zed
_path=="dhcp" | cut host_name, domain
```

#### Suspicious IP Addresses

Connection logs provide reliable IP filtering and subnet grouping.

```zed
_path=="conn" | put classnet := network_of(id.resp_h) | cut classnet | count() by classnet | sort -r
```

#### Detect Files

File analysis supports detection of malware transfers, infected files, and possible sensitive-data movement.

```zed
filename!=null
```

#### SMB Activity

SMB activity is important for detecting enumeration, lateral movement, file sharing abuse, and service exploitation.

```zed
_path=="dce_rpc" OR _path=="smb_mapping" OR _path=="smb_files"
```

#### Known Patterns

Known patterns are alerts generated by security tools, including Zeek notices, Suricata alerts, and signature-based detections.

```zed
event_type=="alert" or _path=="notice" or _path=="signatures"
```

## Exercise: Threat Hunting with Brim | Malware C2 Detection

### Scenario

This exercise investigates a malware campaign associated with Cobalt Strike. The observed chain begins with an employee clicking a link and downloading a file, followed by network performance issues and anomalous traffic.

Investigation objective:

- Import the sample PCAP into Brim.
- Identify suspicious communication patterns.
- Detect malicious C2 activity.
- Use Suricata alerts as supporting evidence.

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-113.png)

### Step 1: Review Available Logs and Frequent Connections

Start by reviewing the available log files to understand available evidence. Then review frequent communications to identify hosts that require attention.

```zed
cut id.orig_h, id.resp_p, id.resp_h | sort | uniq -c | sort -r count
```

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-114.png)

The frequent-connection results indicate that IP ranges such as `10.22.xx` and `104.168.xx` require closer review.

### Step 2: Review Ports and Services

Before narrowing on a suspicious IP, review ports and services.

```zed
_path=="conn" | cut id.resp_p, service | sort | uniq -c | sort -r count
```

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-115.png)

The port data did not immediately show an extreme anomaly, but the volume of DNS records created a useful next pivot.

### Step 3: Review DNS Queries

DNS review helps identify suspicious domains, possible malware infrastructure, and C2 indicators.

```zed
_path=="dns" | count() by query | sort -r
```

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-116.png)

External enrichment, such as VirusTotal review, can help determine whether the observed domains are linked to malicious infrastructure.

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-117.png)

### Step 4: Review HTTP Requests

HTTP requests can reveal file downloads, suspicious URIs, and malicious host relationships.

```zed
_path=="http" | cut id.orig_h, id.resp_h, id.resp_p, method, host, uri | uniq -c | sort value.uri
```

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-118.png)

The HTTP review identifies a file download request from an IP address already considered suspicious.

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-119.png)

VirusTotal enrichment associates the suspicious `104.xx` address with a file, and the combined findings point toward Cobalt Strike activity.

### Step 5: Review Suricata Alerts

Use Suricata alerts as low-hanging fruit after identifying suspicious IPs and DNS/HTTP activity.

```zed
event_type=="alert" | count() by alert.severity,alert.category | sort count
```

![Threat Hunting with Brim - Malware C2 Detection](/images/brim-120.png)

Suricata alert categories provide a high-level view of detected malicious activity. Analysts should investigate individual alert categories and signatures, then continue hunting for additional C2 channels. Cobalt Strike operators often use more than one C2 path.

### Exercise Questions

- What is the name of the file downloaded from the Cobalt Strike C2 connection?
- What is the number of Cobalt Strike connections using port 443?

```zed
event_type=="alert" | dest_port == 443 | cut src_ip, src_port, dest_ip, dest_port | count() by dest_port
```

- There is an additional C2 channel in use. What is the name of the secondary C2 channel?

```zed
event_type=="alert" | alert.category != "Unknown Traffic" | alert.category != "Not Suspicious Traffic" | cut src_ip, src_port, dest_ip, dest_port, alert.signature, alert.category, alert.action | sort alert.signature
```

## Threat Hunting with Brim | Crypto Mining

### Scenario

Crypto mining and cryptojacking are common network-security use cases. Attackers may compromise systems to mine cryptocurrency, but internal misuse can also create mining activity when users install mining software on corporate images.

Why this matters:

- Mining abuses compute power, electricity, and network bandwidth.
- Mining tools may create vulnerabilities or backdoors.
- Mining traffic can cause network performance and stability problems.
- Mining may not always present as traditional malware, so traffic-based investigation is important.

![Threat Hunting with Brim - Crypto Mining](/images/brim-121.png)

### Step 1: Review Available Logs and Frequent Communications

The sample case has fewer available logs, so frequent communication review becomes an important early pivot.

```zed
cut id.orig_h, id.resp_p, id.resp_h | sort | uniq -c | sort -r
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-122.png)

The IP address `192.168.xx` stands out and becomes the primary focus.

### Step 2: Review Ports and Services

```zed
_path=="conn" | cut id.resp_p, service | sort | uniq -c | sort -r count
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-123.png)

Multiple unusual ports are present, moving the investigation closer to confirming anomalous behavior.

### Step 3: Review Transferred Data

Transferred byte counts can support hypotheses about high-volume mining or other abnormal activity.

```zed
_path=="conn" | put total_bytes := orig_bytes + resp_bytes | sort -r total_bytes | cut uid, id, orig_bytes, resp_bytes, total_bytes
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-124.png)

The result shows massive traffic originating from the suspicious IP address.

### Step 4: Review Suricata Alerts

Use Suricata alerts to validate the investigation quickly.

```zed
event_type=="alert" | count() by alert.severity,alert.category | sort count
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-125.png)

The Suricata alerts indicate **Crypto Currency Mining** activity.

### Step 5: Identify the Mining Pool

List associated connection logs for the suspicious IP and enrich destination IPs externally as needed.

```zed
_path=="conn" | 192.168.1.100
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-126.png)

![Threat Hunting with Brim - Crypto Mining](/images/brim-127.png)

The external review identifies the mining server. In real investigations, multiple destination IPs may require review before the event of interest is confirmed.

### Step 6: Map to MITRE ATT&CK

Use Suricata metadata to identify mapped MITRE ATT&CK technique and tactic details.

```zed
event_type=="alert" | cut alert.category, alert.metadata.mitre_technique_name, alert.metadata.mitre_technique_id, alert.metadata.mitre_tactic_name | sort | uniq -c
```

![Threat Hunting with Brim - Crypto Mining](/images/brim-128.png)

| Suricata Category | MITRE Technique Name | MITRE Technique ID | MITRE Tactic Name |
|---|---|---|---|
| Crypto Currency Mining | Resource_Hijacking | T1496 | Impact |

### Exercise Questions

- How many connections used port `19999`?

```zed
_path == "conn" | id.resp_p == 19999 | count()
```

- What is the name of the service used by port `6666`?

```zed
_path == "conn" | id.resp_p == 6666 | cut service
```

- What is the amount of transferred total bytes to `101.201.172.235:8888`?

```zed
_path == "conn" | id.resp_h == 101.201.172.235 OR id.orig_h == 101.201.172.235 | cut id.orig_h, id.orig_p, id.resp_h, id.resp_p, orig_bytes, resp_bytes, orig_ip_bytes, resp_ip_bytes
```

```text
orig_bytes + resp_bytes
```

- What is the detected MITRE tactic ID?

```zed
event_type == "alert" | dest_ip == 101.201.172.235
```
