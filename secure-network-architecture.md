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

## Network Security Policies and Controls  

### Traffic Filtering

Access Control Lists contain Access Control Entries defining a list's profile based on pre-defined criteria
Provides network security, validation, and segmentaion by filtering network traffcibe based on the pre-defined criteria

### VyOS ACL creation and policy definition Example  

`:> set policy access-list <acl_number>` : Create the new access-list policy, defining the ACL number (1 - 2699)  
`:> set policy access-list <acl_number> description <text>` : Set the description of the access list.  
`:> set policy access-list <acl_number> rule <1-65535> action <permit|deny>` : Create a new rule (or ACE) under the ACL and define the action of the rule.  
`:> set policy access-list <acl_number> rule <1-65535> <destination|source> <any|host|inverse-mask|network>` : Define criteria or parameters for the rule to enforce/match.  

### Examples ACL Permitting valid SSH request

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

#### Field Descriptions

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

#### VLAN Tag Components

| Component | Bits | Description | Example Value |
|-----------|------|-------------|---------------|
| **PCP** | 3 bits | Priority Code Point (QoS priority 0-7) | `2` (Normal priority) |
| **DEI** | 1 bit | Drop Eligible Indicator | `0` (Not drop eligible) |
| **VID** | 12 bits | VLAN Identifier (0-4095) | `100` (VLAN 100) |

#### Common VLAN TPIDs

- `0x8100` - Standard 802.1Q VLAN tag
- `0x88A8` - 802.1ad QinQ (Service VLAN)
- `0x9100` - Legacy QinQ

#### Ethernet Frame Notes

- VLAN tag adds 4 bytes to the frame
- VID 0 = Priority tagged (no VLAN)
- VID 4095 = Reserved
- Frame now supports 68-1522 byte range
- Multiple VLAN tags possible (QinQ)

### Example Open vSwitch Configuration

[Open vSwitch](https://www.openvswitch.org/)  
[Open vSwitch Latest Documentation](https://docs.openvswitch.org/en/latest/)  
[Open vSwitch 3.6.1 Manpages](https://www.openvswitch.org/support/dist-docs/) 

`:> ovs-vsctl show` : shows the configuration items  
`:> ovs-vsctl set port <interface> tag=<0-99>` : Alter the configuration database to alter the network interface in the port table to include a tag number.  
`:> ovs-vsctl set port eth0 tag=10 vland_mode=native-untagged` : used for any traffic not tagged and passing through the switch, even with unknown origins  

### VLAN Routing

#### Router on a Stick

VLANS communicate with router through a designated interface on a switch (switch port)  
Trunk: connect the switch to a router  
VLAN traffic is router through the switch port, over the trunk.  
Many VLANs filter to a single Trunk  

#### Trunk Configuration  

Each vendor confgures trunks and switches either open or proprietary protocols  
`:> ovs-vsctl add-br br0` : add a bridge (trunk) named 'br0'  
`:> ovs-vsctl add-port br0 eth0 tag=10` : Adds the physical interface eth0 to bridge br0 as an access port assigned to VLAN 10  

#### Router Configuration

Because 802.1q tags are standardized  
Tell the router how to configure its switch and what tags to accept for each interface  
Virtual Sub-Interfaces allow router to keep each tagged frame separate, acting similarly to physica interfaces, adn commonly defined by the VLAND ID  
Common sub-interface syntax: `<name>.<vlan/sub-interface id>` 

***Example Configuration with VyOS open-source router***

`:> vyos@vyos-rtr# set interfaces ethernet eth0 vif 10 description 'VLAN 10'` : Creates a VLAN subinterface on physical interface `eth0` for VLAN 10 and assigns it a descriptive label  
`:> vyos@vyos-rtr# set interfaces ethernet eth0 vif 10 address '192.168.100.1/24'` : Assigns the IP address 192.168.100.1 with a /24 subnet mask (255.255.255.0) to the VLAN 10 subinterface on eth0, making it a Layer 3 gateway for that VLAN  

### Example open vSwitch configuration file

```md
9a2f8b4e-1c3d-4e5f-9876-123456789abc
    Manager "ptcp:6640:127.0.0.1"
        is_connected: true
    Bridge "br-mgmt"
        Controller "tcp:192.168.1.100:6633"
            is_connected: true
        fail_mode: secure
        datapath_type: system
        Port "br-mgmt"
            Interface "br-mgmt"
                type: internal
        Port "eth1"
            Interface "eth1"
        Port "mgmt-vm1"
            tag: 100
            Interface "mgmt-vm1"
                type: internal
        Port "mgmt-vm2"
            tag: 100
            Interface "mgmt-vm2"
                type: internal
        Port "backup-link"
            tag: 200
            Interface "backup-link"
                type: internal
    Bridge "br-prod"
        Controller "tcp:192.168.1.100:6633"
            is_connected: true
        fail_mode: standalone
        datapath_type: system
        Port "br-prod"
            Interface "br-prod"
                type: internal
        Port "eth0"
            trunks: [10,20,30,40]
            Interface "eth0"
        Port "web-server1"
            tag: 10
            Interface "web-server1"
                type: veth
        Port "web-server2"
            tag: 10
            Interface "web-server2"
                type: veth
        Port "db-server1"
            tag: 20
            Interface "db-server1"
                type: veth
        Port "db-server2"
            tag: 20
            Interface "db-server2"
                type: veth
        Port "app-server1"
            tag: 30
            Interface "app-server1"
                type: veth
        Port "storage-nas"
            tag: 40
            Interface "storage-nas"
        Port "bond0"
            Interface "eth2"
            Interface "eth3"
    Bridge "br-tenant"
        Controller "tcp:192.168.1.100:6633"
        fail_mode: secure
        datapath_type: system
        Port "br-tenant"
            Interface "br-tenant"
                type: internal
        Port "tenant-uplink"
            trunks: [500,501,502,503,600,700]
            Interface "tenant-uplink"
        Port "customer-a-web"
            tag: 500
            Interface "customer-a-web"
                type: internal
        Port "customer-a-db"
            tag: 501
            Interface "customer-a-db"
                type: internal
        Port "customer-b-web"
            tag: 502
            Interface "customer-b-web"
                type: internal
        Port "customer-b-db"
            tag: 503
            Interface "customer-b-db"
                type: internal
        Port "shared-services"
            tag: 600
            Interface "shared-services"
                type: internal
        Port "dmz-services"
            tag: 700
            Interface "dmz-services"
                type: patch
                options: {peer="dmz-patch"}
    Bridge "br-external"
        fail_mode: standalone
        datapath_type: system
        Port "br-external"
            Interface "br-external"
                type: internal
        Port "wan-link1"
            Interface "wan-link1"
                type: dpdk
                options: {dpdk-devargs="0000:05:00.0"}
        Port "wan-link2"
            Interface "wan-link2"
                type: dpdk
                options: {dpdk-devargs="0000:05:00.1"}
        Port "dmz-patch"
            Interface "dmz-patch"
                type: patch
                options: {peer="dmz-services"}
        Port "internet-gw"
            Interface "internet-gw"
                type: gre
                options: {remote_ip="203.0.113.50"}
    ovs_version: "2.17.0"
```

#### Bridge: br-magmt (Management Network)

```md
Purpose: Network management and monitoring
Subnets: 192.168.100.0/24 (VLAN 100), 192.168.200.0/24 (VLAN 200)

┌─────────────────────────────────────────────────────────┐
│                    br-mgmt                              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐    │
│  │ eth1    │ │mgmt-vm1 │ │mgmt-vm2 │ │ backup-link │    │
│  │(trunk)  │ │(tag 100)│ │(tag 100)│ │  (tag 200)  │    │
│  └─────────┘ └─────────┘ └─────────┘ └─────────────┘    │
└─────────────────────────────────────────────────────────┘

VLAN 100: Management VMs (192.168.100.0/24)
VLAN 200: Backup network (192.168.200.0/24)
```

#### Bridge: br-prod (Production Environment)

```md
Purpose: Production application infrastructure
Subnets: Multiple production VLANs

┌─────────────────────────────────────────────────────────────────┐
│                         br-prod                                 │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────────────┐ │
│ │eth0 │ │web  │ │web  │ │db   │ │db   │ │app  │ │storage-nas  │ │
│ │trunk│ │srv1 │ │srv2 │ │srv1 │ │srv2 │ │srv1 │ │  (tag 40)   │ │
│ │10,20│ │tag10│ │tag10│ │tag20│ │tag20│ │tag30│ │             │ │
│ │30,40│ │     │ │     │ │     │ │     │ │     │ │             │ │
│ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────────────┘ │
│                                    ┌─────────────────────────┐  │
│                                    │        bond0            │  │
│                                    │   ┌─────────┬─────────┐ │  │
│                                    │   │  eth2   │  eth3   │ │  │
│                                    │   └─────────┴─────────┘ │  │
│                                    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

VLAN 10: Web tier (10.1.10.0/24)
VLAN 20: Database tier (10.1.20.0/24) 
VLAN 30: Application tier (10.1.30.0/24)
VLAN 40: Storage network (10.1.40.0/24)
```

#### Bridge: br-tenant (multi-tenant Environment)

```md
Purpose: Isolated customer environments
Subnets: Customer-specific VLANs

┌───────────────────────────────────────────────────────────────────┐
│                        br-tenant                                  │
│ ┌─────────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ ┌─────────┐ │
│ │tenant-uplink│ │ cust-a   │ │ cust-a   │ │cust-b   │ │cust-b   │ │
│ │ (trunk)     │ │ web(500) │ │ db(501)  │ │web(502) │ │db(503)  │ │
│ │500,501,502, │ │          │ │          │ │         │ │         │ │
│ │503,600,700  │ │          │ │          │ │         │ │         │ │
│ └─────────────┘ └──────────┘ └──────────┘ └─────────┘ └─────────┘ │
│                ┌─────────┐ ┌─────────┐                            │
│                │ shared  │ │   dmz   │                            │
│                │services │ │services │                            │
│                │(tag 600)│ │(tag 700)│                            │
│                └─────────┘ └─────────┘                            │
└───────────────────────────────────────────────────────────────────┘

VLAN 500: Customer A Web (172.16.10.0/24)
VLAN 501: Customer A DB (172.16.11.0/24)
VLAN 502: Customer B Web (172.16.20.0/24)
VLAN 503: Customer B DB (172.16.21.0/24)
VLAN 600: Shared services (172.16.100.0/24)
VLAN 700: DMZ services (172.16.200.0/24)
```

#### Bridge: br-external (External Connectivity)

```md
Purpose: WAN connections and external services
Subnets: Public IP ranges and tunnels

┌─────────────────────────────────────────────────────────┐
│                   br-external                           │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐     │
│ │wan-link1│ │wan-link2│ │dmz-patch│ │internet-gw  │     │
│ │ (DPDK)  │ │ (DPDK)  │ │ (patch) │ │   (GRE)     │     │
│ │         │ │         │ │         │ │             │     │
│ └─────────┘ └─────────┘ └─────────┘ └─────────────┘     │
└─────────────────────────────────────────────────────────┘

WAN Links: 203.0.113.0/24 (Primary), 198.51.100.0/24 (Backup)
GRE Tunnel: 10.0.0.0/30 (Point-to-point)
```

#### Port Types and Technologies

```md
| Port Type    | Example                       | Description                                                                  | Use Cases                                                    | Configuration Notes                                            |
| ------------ | ----------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------- |
| **Physical** | `eth0`, `eth1`, `enp0s3`      | Standard ethernet interfaces connected to physical hardware                  | Server uplinks, switch connections, direct device attachment | Requires physical NIC, supports all standard ethernet features |
| **Internal** | `br-mgmt`, `mgmt-vm1`, `tap0` | Virtual interfaces created by OVS for host/VM connectivity                   | VM interfaces, container networking, bridge management       | Created in software, appears as network interface to OS        |
| **veth**     | `web-server1`, `container-if` | Virtual ethernet pairs connecting containers/namespaces                      | Docker containers, LXC, network namespaces                   | Always created in pairs, one end in container, one in bridge   |
| **Bond**     | `bond0` (eth2+eth3)           | Link aggregation combining multiple physical interfaces                      | High availability, increased bandwidth, redundancy           | Supports LACP, active-backup, balance modes                    |
| **DPDK**     | `wan-link1`, `dpdk0`          | Data Plane Development Kit interfaces for high-performance packet processing | High-throughput applications, NFV, low-latency networking    | Requires DPDK-enabled NICs, bypasses kernel                    |
| **Patch**    | `dmz-patch`, `inter-br`       | Virtual patch cables connecting two OVS bridges                              | Inter-bridge communication, network segmentation             | Always created in pairs, zero-copy forwarding                  |
| **Tunnel**   | `gre0`, `vxlan1`, `geneve0`   | Overlay network tunnels for remote connectivity                              | Multi-site networking, cloud connectivity, overlay networks  | Supports GRE, VXLAN, Geneve, LISP protocols                    |
| **TAP**      | `vm-tap0`, `qemu-if`          | Userspace packet capture interfaces                                          | VM hypervisor integration, packet inspection                 | Used by QEMU/KVM, userspace applications                       |
| **Dummy**    | `dummy0`                      | Placeholder interfaces for testing/configuration                             | Testing, configuration validation, development               | No actual traffic handling, configuration only                 |
```

#### VLAN Strategy

```md
| VLAN Range  | Purpose               | Subnet Examples                                                | Description                                                 |
| ----------- | --------------------- | -------------------------------------------------------------- | ----------------------------------------------------------- |
| **1-99**    | Infrastructure        | `192.168.1.0/24`, `10.0.0.0/24`                                | Core network infrastructure, management protocols           |
| **100-199** | Management            | `192.168.100.0/24`, `192.168.200.0/24`                         | Network management, monitoring, backup services             |
| **10-40**   | Production tiers      | `10.1.10.0/24`, `10.1.20.0/24`, `10.1.30.0/24`, `10.1.40.0/24` | Multi-tier application environments (web, app, db, storage) |
| **500-599** | Customer environments | `172.16.10.0/24`, `172.16.20.0/24`, `172.16.30.0/24`           | Multi-tenant customer isolation and services                |
| **600-699** | Shared services       | `172.16.100.0/24`, `10.100.0.0/24`                             | Common services, shared infrastructure, utilities           |
| **700-799** | DMZ/External          | `172.16.200.0/24`, `203.0.113.0/24`                            | Demilitarized zone, external-facing services                |
| **800-899** | Development           | `192.168.80.0/24`, `10.80.0.0/24`                              | Development environments, testing, staging                  |
| **900-999** | Guest/Temporary       | `192.168.90.0/24`, `10.90.0.0/24`                              | Guest access, temporary services, isolated testing          |
```

## Zone-Pair Policies and Filtering

### Zone-Pairs

Consider how to apply the requirements of zones to firewall rules and how to define different actions based on the protocol and source/destiatnion zone

Use of direction-based and stateful policy enforcing traffic in a signle direction for each VLAN (e.g. DMZ->LAN or LAN->DMZ)  
Each zone in a topology must have different zone-pairs for each other zone in the topology and every possible direction, providing visibility from a firewall and filtering capabilities

#### Example setting of default policy

***Set default policy for VyOS routers***

`:> set zone-policy zone dmz default-action drop` : set the default policy for the dmz to drop unmatched traffic (default deny)  
`:> set zone-policy zone dmz interface eth0.30` : Assigns the network interface eth0.30 (VLAN 30 subinterface) to the "dmz" security zone. All traffic entering or leaving through this interface will be subject to the DMZ zone's firewall policies  
This set of commands should be duplicated for each zone  

***Generic syntax for adding a zone pair***  
`:> set zone-policy zone <zone A> from <zone B> firewall <name> <ruleset name>` : creates a directional firewall policy `<name>` that applies a specific ruleset `<ruleset name>` to traffic flowing from `<zone B>` to `<zone A>`, enabling granular control over inter-zone communications in a zone-based firewall architecture.

`:> set zone-policy zone LAN from WAN firewall name lan-wan`  
`:> set zone-policy zone WAN from LAN firewall name wan-lan`

### Stateful vs. Stateless Firewalls

#### Overview Comparison Table

```md
| Aspect                       | Stateless Firewalls                         | Stateful Firewalls                            |
| ---------------------------- | ------------------------------------------- | --------------------------------------------- |
| **State Awareness**          | No connection state tracking                | Tracks connection state and context           |
| **Decision Basis**           | Individual packet inspection only           | Connection history and packet relationships   |
| **Memory Usage**             | Minimal (no state tables)                   | Higher (maintains connection state tables)    |
| **Performance**              | Faster per-packet processing                | Slower due to state table lookups             |
| **Security Level**           | Basic filtering                             | Advanced threat protection                    |
| **Configuration Complexity** | Simple rule sets                            | More complex but flexible rules               |
| **Connection Tracking**      | None                                        | Full TCP/UDP session tracking                 |
| **Return Traffic Handling**  | Requires explicit rules for both directions | Automatic handling of established connections |
```

#### Technical Characteristics

```md
| Feature                         | Stateless                             | Stateful                         |
| ------------------------------- | ------------------------------------- | -------------------------------- |
| **Rule Processing**             | Linear rule matching per packet       | Context-aware rule processing    |
| **Connection Table**            | Not maintained                        | Active connection state table    |
| **TCP Sequence Tracking**       | No                                    | Yes - tracks sequence numbers    |
| **Protocol Understanding**      | Basic header inspection               | Deep protocol analysis           |
| **Session Correlation**         | Cannot correlate related packets      | Links packets to sessions        |
| **NAT Compatibility**           | Limited                               | Full NAT state tracking          |
| **Fragmented Packet Handling**  | Each fragment processed independently | Reassembles and tracks fragments |
| **Application Layer Awareness** | None                                  | Can inspect application data     |
```

## Addressing Common Attacks

### DHCP Snooping

a Layer 2 security feature
acts as a firewall between untrusted DHCP clients and trusted DHCP servers
validates DHCP messages, maintains a binding table of legitimate DHCP assignments, and prevents various DHCP-based attacks  

### Attack Prevention Table

```md
| Attack Type           | How DHCP Snooping Prevents                               |
| --------------------- | -------------------------------------------------------- |
| **Rogue DHCP Server** | Blocks DHCP server messages on untrusted ports           |
| **DHCP Starvation**   | Rate limiting prevents excessive DHCP requests           |
| **MAC Spoofing**      | Binding table validates MAC-IP relationships             |
| **IP Spoofing**       | Dynamic ARP Inspection uses binding table for validation |
| **Man-in-the-Middle** | Prevents unauthorized gateway advertisements             |
```

### Dynamic ARP Inspection

 a Layer 2 security feature
 validates ARP packets to prevent ARP spoofing and man-in-the-middle attacks
 intercepts, validates, and filters ARP packets on untrusted ports by checking them against a trusted database of IP-to-MAC address bindings  

 #### Attack Mitigation Table

```md
| Attack Type               | DAI Protection Method                                      |
| ------------------------- | ---------------------------------------------------------- |
| **ARP Spoofing**          | Validates sender MAC/IP against binding database           |
| **ARP Cache Poisoning**   | Prevents malicious ARP replies from being forwarded        |
| **Man-in-the-Middle**     | Blocks attempts to redirect traffic via fake ARP responses |
| **Gateway Impersonation** | Validates gateway MAC address consistency                  |
| **ARP DoS**               | Rate limiting prevents ARP flooding attacks                |
```