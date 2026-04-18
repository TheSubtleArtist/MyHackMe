# NetworkMinder

## NetworkMinder in Forensics

Network forensics provides sufficient information to detect malicious activities, security breaches, and network anomalies based on the network traffic  

Main data types investigated in Network Forensics:

    Live Traffic
    Traffic Captures
    Log Files

NetworkMiner processes and handles packet pictures (PCAP) and live traffic.

## What is NetworkMiner

| Capability                     | Description                                                                 |
|--------------------------------|-----------------------------------------------------------------------------|
| Traffic sniffing              | It can intercept traffic, sniff it, and collect/log packets across a network. |
| Parsing PCAP files                | It can parse PCAP files and display packet contents in detail.                  |
| Protocol analysis            | It can identify the protocols used from the parsed PCAP file.                   |
| OS Fingerprinting               | It can identify the OS ystem or device by analyzing the parsed file. This relies on tools like Satori and p0f. |
| File Extraction              | It can extract images, HTML files, and emails from the parsed PCAP file.        |
| Credential grabbing          | It can extract credentials from the parsed PCAP file.                           |
| Clear text keyword parsing   | It can extract cleartext keywords and strings from the parsed PCAP file.        |  

### Operating Modes

#### Sniffer Mode 

- Although it has a sniffing feature, it is not intended to be used as a primary sniffer.
- The sniffing feature is available only on Windows.
- However, the rest of the features are available on both Windows and Linux.
- Based on experience, the sniffing feature is not as reliable as other features.
- Therefore, it is suggested not to use this tool as a primary sniffer.
- Even the official description identifies it as a "Network Forensics Analysis Tool," though it can also function as a sniffer.
- In other words:
  - It is primarily a Network Forensic Analysis Tool
  - It <includes> a sniffer feature
  - It is not a dedicated sniffer like <Wireshark> and <tcpdump>

#### Packet Parsing / Processing

- NetworkMiner can parse traffic captures to provide a quick overview of the data.
- It helps extract useful information from the investigated capture.
- This mode is mainly suggested to capture <easily accessible insights> ("low-hanging fruit") before deeper analysis.

### Pros and Cons

#### Pros

    fingerprinting
    Easy file extraction
    Credential grabbing
    Clear text keyword parsing
    Overall overview

#### Cons

    Not useful in active sniffing
    Not useful for large pcap investigation
    Limited filtering
    Not built for manual traffic investigation

### Differences Between Wireshark and NetworkMiner

NetworkMiner and Wireshark share similar core features, but they differ in purpose and strengths. While their main functions overlap, certain features are significantly stronger depending on the use case.

**Best Practice:**

- Capture network traffic for offline analysis
- Perform a quick overview of the <captured traffic> using NetworkMiner
- Conduct deeper investigation using <Wireshark>

---

#### Feature Comparison

| Feature                     | NetworkMiner                                      | Wireshark            |
|----------------------------|--------------------------------------------------|----------------------|
| Purpose                    | Quick overview, traffic mapping, data extraction | In-depth analysis    |
| GUI Availability           | ✅                                                | ✅                  |
| Sniffing                   | ✅                                                | ✅                  |
| Handling PCAPs             | ✅                                                | ✅                  |
| Fingerprinting             | ✅                                                | ❌                  |
| Parameter/Keyword Discovery| ✅                                                | Manual              |
| Credential Discovery       | ✅                                                | ✅                  |
| File Extraction            | ✅                                                | ✅                  |
| Filtering Options          | Limited                                          | ✅                  |
| Packet Decoding            | Limited                                          | ✅                  |
| Protocol Analysis          | ❌                                                | ✅                  |
| Payload Analysis           | ❌                                                | ✅                  |
| Statistical Analysis       | ❌                                                | ✅                  |
| Cross-Platform Support     | ✅                                                | ✅                  |
| Host Categorisation        | ✅                                                | ❌                  |
| Ease of Management         | ✅                                                | ✅                  |

## Tool Overview

### Landing Page

Once you open the application, this screen loads up.

### File Menu

Load a pcap or receive a pcap over IP

### Tools Menu

Clear the dashboard  
remove captured data  

### Help Menu

information and updates 

### Case Panel

list of investigated pcap files  
reload/refresh, view metadata details  
remove loaded files  
Viewing Metadata of loaded files

### Hosts

Show identified hosts:  

    - IP
    - MAC
    - OS
    - Open Ports
    - Sent/Recevied packets
    - incoming/outgoing sessions
    - host details

OS fingerptinging uses Satori GitHub  repo and p0f.  
MAC address database uses the mac-ages GitHub repo

### Sessions


    Frame number
    Client and server address
    Source and destination port
    Protocol
    Start time

### DNS

    Frame number  
    timestamp  
    client and server  
    source and destination port  
    IP TTL  
    DNS time  
    Transaction ID and type  
    DNS query and answer  
    Alexa Top 1M (premium mode)  

### Extracted Credentials

    Kerberos hashes  
    NTLM hashes  
    RDP cookies  
    HTTP cookies  
    HTTP requests  
    IMAP  
    FTP   
    SMTP  
    MS SQL  

### Files

    Frame Number   
    Filename  
    Extension  
    Size  
    Source and destination address  
    Source and destinatioin port  
    Protocol  
    Timestamp  
    Reconstructed Path  
    Details  

### Images

Images extracted from investigated pcaps

### Parameters

    Parameter name
    Parameter value
    Frame number
    Source and destination host
    Source and destination port
    Timestamp
    Details

### Keywords

The file menu shows extracted keywords from investigated pcaps. This section provides information on:

    Frame number
    Timestamp
    Keyword
    Context
    Source and destination host
    source and destination port

### Messages

The messages menu shows extracted emails, chats and messages from investigated pcaps. This section provides information on:

    Frame number
    Source and destination host 
    Protocol
    Sender (From)
    Receiver (To)
    Timestamp
    Size

Anomalies

    The anomalies menu shows detected anomalies in the processed pcap. Note that NetworkMiner isn't designated as an IDS. However, developers added some detections for EternalBlue exploit and spoofing attempts.
