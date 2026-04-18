# Snort

## Capabilities

- Live traffic analysis
- Attack and probe detection
- Packet logging
- Protocol analysis
- Real-time alerting
- Modules & Plugins
- Pre-processors
- Cross-platform support for Windows and Linux

## Modes

Here’s your content organized into a structured markdown table:

| Mode                                            | Description                                                                 |
| ----------------------------------------------- | --------------------------------------------------------------------------- |
| Sniffer Mode                                    | Reads and displays IP packets directly in the console application.          |
| Packet Logger Mode                              | Logs all IP packets (both inbound and outbound) that traverse the network.  |
| Network Intrusion Detection System (NIDS) Mode  | Logs packets that are identified as malicious based on user-defined rules.  |
| Network Intrusion Prevention System (NIPS) Mode | Drops packets that are identified as malicious based on user-defined rules. |


## Introduction to IDS/IPS

### Intrusion Detection System (IDS)

Passive moniotring solution  
detects possible malicous activites/patterns, abnormal incidents, policy violateions  
generates alerts for each suspicious event  

#### Network Intrusion Detection System (NIDS)

Moniotrs traffic flow on subnets  
alerts on signatures  

#### Host-based Intrusion Detection System (HIDS)

Moniotrs and investigates traffic flow from a single endpoint  
alerts on signatures  

### Intrusion Protection System (IPS)

Active protection for preventing possible malicious activites/patterns, abnormal incidents, and policy violations. 
stops/prevents/terminates suspicious events  

#### Network Intrusion Prevention System (NIPS)

Moniotrs traffic flows to protect an entire subnet
Signature based

#### Behavior-based Intrusion Prevention System

Observes traffic flows on the subnet to identify behavioral abnomolies  
requires a training period (baselining) to learn normal traffic and differentiation anamalous traffice
securiyt breaches during the training period create incorrect perception of "normal" traffic

#### Wireless Intrusion Prevention System (WIPS)

moniotrs wireless network  
signature-based  

#### Host-based Intrusion Prevention System (HIPS)

Protects traffic flow from single endpoint  
signature-based

### Detection / Prevention Techniques  

Here’s the structured markdown table based on your text:

| Technique       | Approach                                                                                                                                             |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Signature-Based | This technique relies on rules that identify specific patterns of known malicious behavior. It helps detect known threats.                           |
| Behaviour-Based | This technique identifies new threats that bypass signature detection. It compares normal behavior with abnormal behavior to detect unknown threats. |
| Policy-Based    | This technique compares detected activities against system configuration and security policies. It helps detect policy violations.                   |

## First Interaction with Snort

`:> snort -v` : identify the snort version

`:> snort -c /etc/snort/snort.conf -T` : identify (`-c`) and test (`-T`) the configuration files (`snort.conf`)

configuration files serve as all-in-one management files containing rles, plugins, detection mechanisms, default actions, and output settings.
only one configuration file can be used at a time  

## Operation Mode 1: Sniffer Mode

| Parameter | Description |
|-----------|-------------|
| -v        | Verbose. Display the TCP/IP output in the console. |
| -d        | Display the packet data (payload). |
| -e        | Display the link-layer (TCP/IP/UDP/ICMP) headers. |
| -X        | Display the full packet details in HEX. |
| -i        | This parameter helps define a specific network interface to listen to or sniff. Once you have multiple interfaces, you can choose a specific interface to sniff. |


## Operation Mode 2: Packet Logger Mode

log sniffed packets.

Here’s your content organized into a structured markdown table:

| Parameter | Description                                                                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -l        | Logger mode, target log, and alert output directory. Default output folder is `/var/log/snort`. The default action is to dump as tcpdump format in `/var/log/snort`. |
| -K ASCII       | Log packets in ASCII format.                                                                                                                                         |
| -r        | Reading option: Review the logged events in Snort.                                                                                                                   |
| -n        | Specify the number of packets to be processed or read. Snort will stop after reading the specified number of packets.                                                |

### Logfile Ownership

Snort requires root rights to sniff traffic  
Log files, then, become owned by `root`  
investigation of logfiles required `root` permissions or actions to change ownership  

## Operation Mode 3: IDS/IPS

Here’s your content organized into a structured markdown table:

| Parameter | Description                                                                                                    |
| --------- | -------------------------------------------------------------------------------------------------------------- |
| -c        | Defining the configuration file.                                                                               |
| -T        | Testing the configuration file.                                                                                |
| -N        | Disable logging.                                                                                               |
| -D        | Background mode.                                                                                               |
| -A        | Alert modes:                                                                                                   |
|           | **Full**: Full alert mode, providing all possible information about the alert. This mode is the default.       |
|           | **Fast**: Displays the alert message, timestamp, source and destination IP addresses, along with port numbers. |
|           | **Console**: Provides fast style alerts on the console screen.                                                 |
|           | **cmg**: CMG style, basic header details with payload in hex and text format.                                  |
|           | **None**: Disables alerting.                                                                                   | 



## Operation Mode 4: PCAP Investigation

```text
Here’s your content organized into a structured markdown table with the addition of the "pcap" term where applicable, and an example command column:

| Parameter       | Description                                       | Example Command                         |
| --------------- | ------------------------------------------------- | --------------------------------------- |
| -r / --pcap-single= | Read a single pcap.                               | `snort -r single.pcap`                  |
| --pcap-list=""      | Read pcaps provided in command (space separated). | `snort -pcap--list="file1.pcap file2.pcap"` |
| --pcap-show         | Show name on console during processing.           | `snort -pcap--show -r example.pcap`         |
```

## Snort Rules

### Rule Types

Community Rules - Free ruleset under the GPLv2. Publicly accessible, no need for registration.  
Registered Rules - Free ruleset (requires registration). This ruleset contains subscriber rules with 30 30-day delay.  
Subscriber Rules (Paid) - Paid ruleset (requires subscription). This ruleset is the main ruleset and is updated twice a week (Tuesdays and Thursdays).  

### Snort Rule Structure

```text
[action] [protocol] [source IP] [source port] [direction] [destination IP] [destination port] ([rule options])
```

Here’s the Snort rule surrounded with the proper markdown code block for easy copying and pasting into a markdown document:

```snort
alert tcp $EXTERNAL_NET [80,143] -> $HOME_NET any
(
    msg:"MALWARE-OTHER Win.Ransomware.Agent payload download attempt";
    reference: "CVE-XXXX-XXXX"
    flow:to_client,established;
    file_data; content:"secret_encryption_key",fast_pattern,nocase;
    content: match specific payload data by ASCII, HEX, both"
    nocase; 
    fast_pattern;
    service:http,imap;
    classtype:trojan-activity;
    rev:2
    sid:1;
)
```

You can now copy and paste this directly into any markdown document, and it will be displayed correctly in a code block.

## Snort2 Operation Logic: Points to Remember
