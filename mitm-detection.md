# Man-in-the-Middle Detection

## ## Scenario

A routine network monitoring alert at Acme Corp revealed unusual traffic patterns suggesting a possible Man-in-the-Middle (MITM) attack inside the corporate LAN. Over several days, an attacker quietly intercepted communications, redirected connections, and captured user credentials.

- ARP Spoofing (network interception).
- DNS Spoofing (redirection).
- SSL Stripping (credential capture).

## MITM Attacks Overview

Attacker secretly intercepts and potentially alters communciation between two parties.
steasl sensitive data

### How MITM Attacks Work

#### Interception

Attacker inserts themself into a comnication stream

- exploit weaknesses in netwokr protocosl
- ARP, DNS, or IP Spoofing

#### Manipulation / Decryption

attacker accesses or modifies communication

- decrypt encoded data
- inject malioucs or harmful content

#### Common MITM Attacks

| Attack Type              | Description                                                                 | Key Mechanism / Notes                                      |
|-------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------|
| Packet Sniffing         | Capturing unencrypted data packets exchanged over a network, often on open Wi-Fi. | Relies on lack of encryption (e.g., HTTP, unsecured networks). |
| Session Hijacking       | Stealing and using session tokens to impersonate authenticated users.       | Exploits weak session management or exposed cookies.        |
| SSL Stripping           | Downgrading HTTPS connections to insecure HTTP to steal or alter transmitted data. | Intercepts and modifies requests to remove encryption.      |
| DNS Spoofing            | Redirecting legitimate website traffic to fraudulent domains by manipulating DNS responses. | Also known as DNS cache poisoning.                         |
| IP Spoofing             | Crafting malicious IP packets that appear to come from trusted systems.     | Used to bypass IP-based authentication or launch attacks.   |
| Rogue Wi-Fi Access Point| Creating fake wireless networks to intercept user traffic.                  | Often mimics legitimate SSIDs (Evil Twin attack).           |

### MITM and the Cyber Kill Chain

* Effective analysis requires placing alerts in the context of attacker behavior
* Individual indicators gain meaning when mapped to Tactics, Techniques, and Procedures (TTPs)
* The Cyber Kill Chain is a common model that outlines the stages of a cyber intrusion

#### Phases of the Cyber Kill Chain

| Stage                  | Description                                                                                  | Key Notes                                      |
|------------------------|----------------------------------------------------------------------------------------------|------------------------------------------------|
| Reconnaissance         | The adversary gathers intelligence on the target to identify vulnerabilities.               | Passive or active information gathering.       |
| Weaponization          | The adversary combines an exploit with a malicious payload into a deliverable package.      | Prepares malware tailored to the target.       |
| Delivery               | The adversary transmits the weaponized package to the target environment.                   | Common methods: email, web, USB, etc.          |
| Exploitation           | Malicious code is triggered to exploit a vulnerability and gain initial access.             | Targets software, hardware, or human flaws.    |
| Installation           | The adversary installs malware or establishes persistence on the compromised system.        | Ensures continued access.                      |
| Command & Control (C2) | The adversary establishes a covert channel to communicate with the compromised system.      | Enables remote control and data exchange.      |
| Actions on Objectives  | The adversary achieves their goals (e.g., data exfiltration, destruction, lateral movement).| Final stage of the attack lifecycle.           |

#### Situating MITM within the Cyber Kill Chain

##### **As an Exploitation Technique**

  * Exploits trust and design limits in core protocols (e.g., TCP/IP, ARP)
  * Manipulates traffic to intercept communication (session interception)
  * Breaks network integrity and enables eavesdropping or active manipulation
  * Provides an initial foothold

##### **As an Installation Vector**

  * Requires a Man-in-the-Middle (MitM) position
  * Attacker controls the data stream to deliver payloads
  * Can inject exploits, malware droppers, or RATs into unencrypted traffic
  * Aligns with the Installation phase (deploying persistent malicious tools)

### Detecting ARP Spoofing

#### Address Resolution Protocol (ARP)

Maps IP addresses to MAC addresses in a local network.  

ARP spoofing sends fake ARP replies ot track devices into associating the attacker's MAC with a legitimate IP. OFten targets the default gateway. Allows attacker to intercept, modify, and/or redirect traffic

ARP has no authentication requirement

- `is-at` messages are sent unsolicited and poisons the ARP cache.
- results in the traffice to the default gateway traveling through the MITM first.

### Indicators of Attack

- **Duplicate MAC-to_IP Mappings:** Multiple MAC addresses claiming the same IP address indicates impersonation
- **Unsolicited ARP REplies:** High number of ARP replies without matching requests ("gratuitous ARP").
- **Abnormal ARP Traffic Volume:** Large number of ARP packets in short intervals
- **Unusual Traffic Routing:**  Traffic is reouteer the the attacker's MAC
- **Gateway Redirection Pattterns:** Multiple destination MACs for the same gateway IP
- **ARP Probe / Reply Loops:** Many ARP requests with `who has 192.168.1.x? tell 192.168.1.y` patterns

## DNS Spoofing

or DNS Cache Poisoning