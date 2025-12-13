# Secure Network Architecture

## Common Secure Network Architecture

Perperly implementing VLANs as a security boundary using security zones.  
Security zones define what or who is in a VLAND and how traffic travels in and out  

Common security zones in a layered network architecture promte defense-in-depth.
Security zones and access controls physically direct how and where traffic goes. Traffic rules are governed by organizaitonla security policy


| Zone                         | Trust Level       | Description                                                                                                                                                  | Typical Examples                                                                                               | Purpose/Notes                                                                                                                               |
| ---------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **External**                 | Untrusted         | All devices and entities outside of the organization's network or asset control. This includes the public internet and any external connections.             | Internet users, external devices connecting to public services                                                 | Highest risk zone; access is heavily restricted and monitored. No direct access to internal resources.                                      |
| **DMZ (Demilitarized Zone)** | Semi-Trusted      | A buffer zone that separates untrusted external networks from internal resources. Hosts public-facing services that need to be accessible from outside.      | Public web servers, email servers, DNS servers, BYOD/remote users/guests in some setups                        | Provides an additional layer of security by isolating exposed services. If compromised, attackers still face barriers to internal networks. |
| **Trusted**                  | Trusted           | Internal networks or devices where standard user and business operations occur. Suitable for resources without highly confidential or sensitive information. | User workstations, printers, B2B partner connections                                                           | Basic internal access; protected from external threats but allows normal business traffic flow.                                             |
| **Restricted**               | Highly Restricted | Contains high-risk or high-value servers and databases holding sensitive or critical information. Access is tightly controlled.                              | Domain controllers, database servers with client information, application servers                              | Extra protections (e.g., additional firewalls, strict access controls) to prevent lateral movement in case of breach.                       |
| **Management**               | Highly Restricted | Dedicated to devices and services for network and infrastructure management. Often isolated to prevent compromise of administrative tools.                   | Virtualization management hosts (e.g., vCenter), backup servers, jump hosts, out-of-band management interfaces | Less common as a separate zone; sometimes merged with Restricted or Audit. Highly privileged access requires strong isolation.              |
| **Audit**                    | Highly Restricted | Dedicated to security monitoring, logging, and auditing tools. Isolates sensitive telemetry to protect detection capabilities.                               | SIEM systems, log servers, intrusion detection systems, telemetry collectors                                   | Less common; sometimes grouped with Management. Critical for maintaining visibility and responding to incidents without interference.       |


## Network Segmentation

VLANs are configured on a switch by adding a "tag" to a frame.
RFC: 802.1q (dot1q)

### Ethernet Frame Structure

```md
|  Preamble  | SFD |  Dest MAC  |  Src MAC   | Type/Len |    Data Payload    |  FCS  |
|  (7 bytes) |(1B) |  (6 bytes) |  (6 bytes) | (2 bytes)|   (46-1500 bytes)  |(4 B)  |
+------------+-----+------------+------------+----------+--------------------+-------+
| 10101010...| 171 | FF:FF:FF:  | AA:BB:CC:  |   0800   |  IP Header + Data  | CRC32 |
| (repeated) |     | FF:FF:FF   | DD:EE:FF   | (IPv4)   |                    |       |
+------------+-----+------------+------------+----------+--------------------+-------+

Total Frame Size: 64 - 1518 bytes (excluding Preamble and SFD)
```

#### Field Descriptions:

| Field | Size | Description |
|-------|------|-------------|
| **Preamble** | 7 bytes | Alternating 1s and 0s (10101010) for synchronization |
| **SFD** | 1 byte | Start Frame Delimiter (10101011) - marks frame start |
| **Destination MAC** | 6 bytes | Target device's hardware address |
| **Source MAC** | 6 bytes | Sender's hardware address |
| **Type/Length** | 2 bytes | Protocol type (>1536) or payload length (≤1500) |
| **Data Payload** | 46-1500 bytes | Actual data being transmitted |
| **FCS** | 4 bytes | Frame Check Sequence (CRC-32 checksum) |

#### Notes

- Minimum payload is 46 bytes (padded if necessary)
- Inter-frame gap of 12 bytes between frames
- Preamble and SFD are often considered separate from the frame itself



### Ethernet Frame with VLAN Tag (802.1Q)

```md
|  Preamble  | SFD |  Dest MAC  |  Src MAC   | VLAN Tag | Type/Len |    Data Payload    |  FCS  |
|  (7 bytes) |(1B) |  (6 bytes) |  (6 bytes) | (4 bytes)| (2 bytes)|   (46-1500 bytes)  |(4 B)  |
+------------+-----+------------+------------+----------+----------+--------------------+-------+
| 10101010...| 171 | 00:1A:2B:  | 00:50:56:  |   8100   |   0800   |  IP Header + Data  | CRC32 |
| (repeated) |     | 3C:4D:5E   | A1:B2:C3   | 2064 0100| (IPv4)   |                    |       |
+------------+-----+------------+------------+----------+----------+--------------------+-------+
                                              |   TPID   |   TCI    |
                                              | (2 bytes)| (2 bytes)|

Total Frame Size: 68 - 1522 bytes (excluding Preamble and SFD)
```

#### VLAN Tag Breakdown (4 bytes total)

```md
    TPID (Tag Protocol Identifier)        TCI (Tag Control Information)
    ┌─────────────────────────────┐       ┌─────────────────────────────┐
    │          0x8100             │       │  PCP │DEI│     VID         │
    │         (2 bytes)           │       │ (3b) │(1)│   (12 bits)     │
    └─────────────────────────────┘       └─────────────────────────────┘
                                          │  2   │ 0 │    100 (0x064)  │
                                          └─────────────────────────────┘

Binary representation of TCI (0x2064):
┌───┬─┬─────────────┐
│010│0│000001100100│ = 0x2064
└───┴─┴─────────────┘
PCP=2 DEI=0 VID=100
```

#### VLAN Tag Components:

| Component | Bits | Description | Example Value |
|-----------|------|-------------|---------------|
| **PCP** | 3 bits | Priority Code Point (QoS priority 0-7) | `2` (Normal priority) |
| **DEI** | 1 bit | Drop Eligible Indicator | `0` (Not drop eligible) |
| **VID** | 12 bits | VLAN Identifier (0-4095) | `100` (VLAN 100) |

#### Common VLAN TPIDs

- `0x8100` - Standard 802.1Q VLAN tag
- `0x88A8` - 802.1ad QinQ (Service VLAN)
- `0x9100` - Legacy QinQ

#### Notes

- VLAN tag adds 4 bytes to the frame
- VID 0 = Priority tagged (no VLAN)
- VID 4095 = Reserved
- Frame now supports 68-1522 byte range
- Multiple VLAN tags possible (QinQ)


## Zone-Pair Policies and Filtering

## Validating Network Traffic

## Addressing Common Attacks

