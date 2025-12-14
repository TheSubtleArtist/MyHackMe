# Microsoft Windows Hardening

## General Concepts

### Services

Windows Services create and manage critical functions such as network connectivity, storage, memory, sound, user credentials, and data backup and runs automatically in the background. 

Services are managed by the Service Control Manager panel and divided into three categories

- Local
- Network
- System

#### services.msc

***Purpose:***
Services.msc is a built-in Windows administrative tool that provides a graphical interface for managing Windows services - background programs that run continuously to support system functions and applications.

***Scope:***

Displays all installed services on the local computer or remote systems
Covers system services (essential Windows functions), application services (third-party software), and network services
Available across all Windows versions and accessible to users with administrative privileges

***Key Capabilities:***

Service Control: Start, stop, pause, resume, and restart services
Startup Configuration: Set services to start automatically, manually, or disable them entirely
Service Monitoring: View real-time status, process IDs, and resource usage
Properties Management: Configure service accounts, recovery actions, dependencies, and security permissions
Remote Management: Manage services on networked computers
Troubleshooting: Identify problematic services affecting system performance or stability

#### Microsoft Configuration Manager

***Purpose:***
Microsoft Configuration Manager is an enterprise-level systems management platform designed to deploy, manage, and secure devices and applications across large organizations. It provides centralized IT infrastructure management for Windows-based environments.

***Scope:***

Manages thousands of devices including desktops, laptops, servers, and mobile devices
Supports Windows operating systems, Microsoft applications, and third-party software
Operates through a hierarchical site structure with primary and secondary sites
Integrates with Microsoft Intune for cloud-based device management

***Key Capabilities:***

Software Deployment: Automated installation, updates, and removal of applications and operating systems
Patch Management: Centralized Windows Update deployment and compliance monitoring
Operating System Deployment: Image-based OS installation and migration across multiple devices
Inventory Management: Hardware and software asset tracking and reporting
Compliance Management: Policy enforcement and security configuration assessment
Remote Control: Direct device access for troubleshooting and support
Reporting: Comprehensive dashboards and reports on system health, compliance, and usage
Mobile Device Management: Basic smartphone and tablet management capabilities

***Target Users:***
Enterprise IT departments, system administrators, and organizations requiring centralized management of 500+ devices.


### Windows Registry

**Purpose:**
The Windows Registry is a hierarchical database that stores low-level configuration settings, system preferences, hardware information, and application data for the Windows operating system and installed programs. It serves as the central repository for critical system and user configuration data.

**Scope:**

- **System-wide Configuration:** Hardware settings, device drivers, system services, and Windows features
- **User Profiles:** Individual user preferences, desktop settings, and application configurations
- **Application Data:** Installation paths, license keys, user preferences, and program states
- **Security Settings:** User permissions, group policies, and access controls
- **Network Configuration:** TCP/IP settings, domain information, and network protocols

**Key Capabilities:**

- **Centralized Storage:** Single location for all configuration data across the system
- **Hierarchical Organization:** Structured in hives (HKLM, HKCU, etc.) with keys and values
- **Real-time Access:** Applications can read/write configuration data during runtime
- **Backup and Restore:** System restore points and manual registry backups
- **Remote Management:** Group Policy integration for enterprise environments
- **Security Control:** Permission-based access control and audit capabilities
- **Data Types:** Support for strings, binary data, DWORD values, and multi-string entries

**Modern Management Tools:**

- Registry Editor (regedit.exe)
- Group Policy Management
- PowerShell registry cmdlets
- System Configuration Utility (msconfig)

**Security Considerations:**

- Administrative privileges required for system-level changes
- Regular backup recommended before modifications
- Malware often targets autorun keys and system service entries
- User Account Control (UAC) provides additional protection layers

### Event Viewer

**Purpose:**
Event Viewer is a built-in Windows management tool that displays detailed logs of system events, application activities, and security incidents. It serves as the central monitoring hub for diagnosing system issues, tracking user activities, and investigating security events.

**Scope:**

- **System Events:** Hardware failures, driver issues, service starts/stops, and boot processes
- **Application Events:** Software crashes, installation logs, and program error messages
- **Security Events:** User logons/logoffs, privilege escalations, and access attempts
- **Setup Events:** Windows updates, feature installations, and system configuration changes
- **Forwarded Events:** Centralized logs from remote systems in enterprise environments

**Key Capabilities:**

- **Real-time Monitoring:** Live event tracking with automatic refresh
- **Log Filtering:** Search by event ID, source, level, keywords, and time ranges
- **Event Correlation:** Link related events across different log categories
- **Custom Views:** Create personalized filters for specific monitoring needs
- **Log Management:** Archive, clear, and export logs in multiple formats (XML, CSV, TXT)
- **Remote Log Access:** View events from networked computers with proper permissions
- **Event Subscriptions:** Collect logs from multiple systems centrally

**Limitations:**

- **Log Rotation:** Older events automatically deleted when maximum file size reached
- **Performance Impact:** Extensive logging can affect system performance
- **Storage Constraints:** Default log sizes may be insufficient for high-activity environments
- **Limited Analysis Tools:** Basic filtering; lacks advanced analytics and visualization
- **Overwhelming Volume:** High-traffic systems generate massive amounts of data
- **Retention Policies:** No built-in long-term archival capabilities
- **Query Limitations:** Complex searches require PowerShell or third-party tools
- **Real-time Alerting:** No native notification system for critical events

**Security Applications:**

- **Incident Investigation:** Track failed logon attempts, privilege abuse, and unauthorized access
- **Compliance Auditing:** Monitor file access, policy changes, and administrative actions
- **Threat Detection:** Identify suspicious patterns, malware activities, and system compromises
- **Forensic Analysis:** Detailed timestamps and event sequences for security investigations
- **Account Monitoring:** Track user account creation, modification, and deletion

**Access:** Available through Administrative Tools, Computer Management, or by running `eventvwr.msc`.

Essential for system administrators, security analysts, and IT professionals performing troubleshooting and security monitoring.


### Telemetry

**Review of Current Understanding:**

**Accurate Information:**
- UTC (Universal Telemetry Client) services and diagtrack.dll references
- Local storage location (`%ProgramData%\Microsoft\Diagnosis`)
- DiagTrack service accessibility through Services console
- Data encryption during local storage

**Information Requiring Updates:**
- **Timing:** Data transmission is not fixed at 15 minutes; it varies based on telemetry level, network conditions, and data type
- **Scope:** Description is too narrow; telemetry covers much more than crash logs
- **User Control:** Missing information about user configuration options and privacy controls
- **Modern Context:** Lacks mention of current privacy concerns and regulatory compliance

---

**Updated Microsoft Telemetry Summary:**

**Purpose:**
Microsoft Telemetry is a comprehensive data collection system designed to gather diagnostic, usage, and performance information from Windows devices and applications to improve software quality, security, and user experience across Microsoft's ecosystem.

**Scope:**

- **Diagnostic Data:** System crashes, error reports, performance metrics, and hardware compatibility
- **Usage Analytics:** Feature utilization, user interaction patterns, and application performance
- **Security Intelligence:** Threat detection data, malware signatures, and attack patterns
- **Quality Assurance:** Software reliability metrics, update success rates, and compatibility issues
- **Product Development:** Feature adoption rates and user workflow analysis

**Key Capabilities:**

- **Automated Collection:** Seamless background data gathering through UTC services
- **Configurable Levels:** Basic, Enhanced, and Full telemetry settings with user control
- **Real-time Processing:** Immediate analysis for security threats and critical issues
- **Encrypted Transmission:** Secure data transfer and local storage protection
- **Cross-platform Integration:** Data collection across Windows, Office, and cloud services
- **Privacy Controls:** Diagnostic Data Viewer and deletion capabilities

**Limitations:**

- **Privacy Concerns:** Extensive data collection raises user privacy questions
- **Performance Impact:** Continuous monitoring can affect system resources
- **User Control:** Limited granular control over specific data types collected
- **Transparency:** Some collected data types not fully disclosed to users
- **Network Dependency:** Requires internet connectivity for data transmission
- **Storage Overhead:** Local caching consumes disk space before transmission

**Target Users:**

- **Primary:** Microsoft (for product improvement and security analysis)
- **Secondary:** Enterprise administrators (through configuration policies)
- **End Users:** Benefit from improved software quality and security

**Security Relevance:**

- **Threat Intelligence:** Contributes to Windows Defender and security update development
- **Vulnerability Detection:** Identifies security weaknesses and attack patterns
- **Privacy Risks:** Potential exposure of sensitive user behavior and system information
- **Compliance Considerations:** Subject to GDPR, CCPA, and other privacy regulations
- **Enterprise Controls:** Group Policy and MDM settings for organizational privacy management

**Management:** 
Accessible through Settings > Privacy & Security > Diagnostics & Feedback, Services console (DiagTrack), and Group Policy in enterprise environments.

## Identity & Access Management

### Standard and Administrative Accounts 

**Standard User Account:**
- Limited system permissions for day-to-day computing tasks
- Can run most applications, access personal files, and modify user-specific settings
- Cannot install software, modify system settings, or access other users' data
- Requires administrator approval (UAC prompt) for elevated operations

**Administrator Account:**
- Full system control with elevated privileges
- Can install/uninstall software, modify system settings, and access all files
- Can create/delete user accounts and change security policies
- Should be reserved for administrative tasks only

**Key Differences:**

| Capability | Standard User | Administrator |
|------------|---------------|---------------|
| Install Software | No (requires approval) | Yes |
| Modify System Settings | No | Yes |
| Access Registry | Limited | Full access |
| Manage Services | No | Yes |
| Create User Accounts | No | Yes |
| Access Other User Data | No | Yes |

**Security Value:**

**Defense in Depth:**

- **Privilege Separation:** Limits damage from malware by restricting system-level access
- **User Account Control (UAC):** Prompts for elevation prevent unauthorized system changes
- **Attack Surface Reduction:** Standard accounts limit what malicious software can modify
- **Accidental Prevention:** Reduces risk of unintentional system configuration changes

**Authentication Options:**

- **Traditional:** Username and password
- **Windows Hello PIN:** Device-specific numeric code
- **Biometric:** Fingerprint, facial recognition, or iris scanning
- **Security Keys:** FIDO2-compatible hardware tokens
- **Picture Password:** Touch-based gesture authentication

**Best Practices:**

- Use standard accounts for daily activities
- Enable administrator account only when performing system administration
- Implement strong authentication (Windows Hello + PIN/biometrics)
- Regular password updates and complexity requirements
- Enable account lockout policies to prevent brute force attacks

**Management Locations:**

- Settings > Accounts (modern interface)
- Control Panel > User Accounts (legacy interface)
- Computer Management > Local Users and Groups (advanced)
- Active Directory Users and Computers (enterprise environments)

**Enterprise Integration:**

- Active Directory domain accounts
- Azure AD integration for cloud-based identity management
- Group Policy for centralized account management
- Microsoft Intune for mobile device management

This account separation model forms the foundation of Windows security architecture, implementing the principle of least privilege to minimize security risks.

### User Account Control (UAC)

**Purpose:**
User Account Control (UAC) is a Windows security feature that helps prevent unauthorized changes to the operating system by requiring explicit approval for actions that could affect system security or stability. It creates a secure boundary between standard user operations and administrative functions.

**How UAC Works:**

- **Token Filtering:** Administrators receive two security tokens - standard user and full admin
- **Elevation Prompts:** System requests explicit permission before granting elevated privileges
- **Secure Desktop:** UAC prompts display on isolated desktop to prevent tampering
- **Process Isolation:** Applications run with standard privileges until elevation approved

**UAC Security Levels:**

1. **Always Notify:** Maximum security - prompts for all administrative actions
2. **Default Setting:** Prompts when programs attempt system changes (recommended)
3. **Notify without Secure Desktop:** Prompts appear but can be interfered with
4. **Never Notify:** UAC disabled - no prompts (not recommended)

**Prompt Types:**

- **Consent Prompt:** Admin users confirm legitimate actions
- **Credential Prompt:** Standard users must enter admin credentials
- **Information Prompt:** Notification of system-initiated changes
- **Red Shield:** Indicates potentially dangerous or unsigned software

**Security Benefits:**

- **Malware Mitigation:** Prevents silent installation of malicious software
- **Privilege Escalation Control:** Audits and controls administrative access
- **User Awareness:** Makes users conscious of security-sensitive operations
- **System Integrity:** Protects critical system files and registry areas
- **Attack Surface Reduction:** Limits damage from compromised applications

**Common UAC Triggers:**

- Software installation/uninstallation
- System configuration changes
- Registry modifications (HKEY_LOCAL_MACHINE)
- Driver installation
- Windows service management
- Firewall rule modifications
- Task Scheduler administrative tasks

**Limitations:**

- **User Fatigue:** Frequent prompts may lead to automatic approval
- **Bypass Methods:** Certain system processes can elevate without prompts
- **Social Engineering:** Users may approve malicious elevation requests
- **Performance Impact:** Minor overhead from token filtering and prompts
- **Application Compatibility:** Some legacy software may not function properly

**Enterprise Management:**

- **Group Policy:** Centralized UAC configuration across domain
- **Registry Settings:** Fine-grained control over UAC behavior
- **Audit Logging:** Track elevation attempts in Event Viewer
- **Application Whitelisting:** Bypass UAC for trusted applications

**Best Practices:**

- Keep UAC enabled at default or higher security level
- Educate users about legitimate vs. suspicious elevation requests
- Regularly review UAC audit logs for unusual activity
- Use standard accounts for daily operations
- Implement application control policies in enterprise environments

**Access Locations:**

- Control Panel > User Accounts > Change User Account Control Settings
- Settings > Accounts > Family & other users (limited options)
- Group Policy: Computer Configuration > Windows Settings > Security Settings

UAC remains a critical component of Windows' defense-in-depth security strategy, providing both technical controls and user awareness for privilege management.

#### Local and Group Policy Editor Summary

**Overview:**
Windows Policy Editors are administrative tools that provide granular control over system behavior, security settings, and user environments through centralized configuration management. Two primary tools serve different scopes: Local Group Policy Editor for individual machines and Group Policy Management Console for domain environments.

**Local Group Policy Editor (gpedit.msc):**

- Manages policies on individual Windows machines
- Available in Windows Pro, Education, and Enterprise editions
- Affects all users on the local computer
- Limited compared to domain-based Group Policy

**Group Policy Management Console (gpmc.msc):**

- Enterprise tool for Active Directory domain environments
- Centralized policy management across multiple computers
- Supports policy inheritance and delegation
- Available on Windows Server and administrative workstations

##### Policy Categories

**Computer Configuration:**

- **Windows Settings:** Security policies, startup/shutdown scripts, software installation
- **Administrative Templates:** Registry-based settings for Windows components
- **Security Settings:** Password policies, account lockout, user rights, audit policies

**User Configuration:**

- **Windows Settings:** Logon/logoff scripts, folder redirection, Internet Explorer maintenance
- **Administrative Templates:** User interface restrictions, application settings
- **Control Panel Settings:** Desktop appearance, Start menu configuration

##### Key Capabilities

- **Security Hardening:** Implement defense-in-depth security configurations
- **Application Control:** Software restriction policies and AppLocker rules
- **User Environment Management:** Desktop standardization and resource access control
- **System Configuration:** Windows Update settings, power management, network policies
- **Compliance Enforcement:** Regulatory and organizational policy implementation
- **Troubleshooting:** Policy modeling and result analysis tools

##### Modern Policy Management

**Cloud-Based Solutions:**

- **Microsoft Intune:** Mobile Device Management (MDM) and Mobile Application Management (MAM)
- **Azure AD Group Policy:** Cloud-delivered policies for hybrid environments
- **Configuration Service Providers (CSPs):** Modern policy delivery mechanism
- **Windows Autopilot:** Automated device configuration and policy deployment

**Hybrid Approaches:**

- **Co-management:** SCCM and Intune integration
- **Cloud-attached:** On-premises Group Policy with cloud analytics
- **Administrative Templates:** ADMX/ADML files for modern applications

**Security Applications:**

- **Zero Trust Implementation:** Device compliance and conditional access policies
- **Endpoint Protection:** Windows Defender configuration and threat response
- **Data Loss Prevention:** File access restrictions and encryption policies
- **Identity Management:** Authentication methods and session controls
- **Vulnerability Management:** Update policies and security baseline enforcement

**Implementation Scenarios:**

- **Standalone Workstations:** Local policies for individual device hardening
- **Small Business:** Basic Group Policy for file servers and domain controllers
- **Enterprise:** Complex policy hierarchies with organizational unit (OU) structure
- **Cloud-First:** Intune-based policy management for modern workplace

**Best Practices:**

- **Testing Environment:** Validate policies before production deployment
- **Incremental Deployment:** Gradual rollout to minimize business disruption
- **Documentation:** Maintain policy inventory and change management records
- **Monitoring:** Regular policy compliance reporting and troubleshooting
- **Backup and Recovery:** Group Policy object backup and disaster recovery procedures

**Limitations:**
- **Windows Home:** No built-in Group Policy Editor support
- **Complexity:** Steep learning curve for advanced configurations
- **Troubleshooting:** Policy conflicts and inheritance issues can be difficult to diagnose
- **Performance Impact:** Excessive policies can slow system startup and logon times

### Windows Password Policies

**Overview:**
Windows Password Policies provide security controls for user authentication through configurable requirements for password complexity, history, aging, and account protection. These policies form a foundational layer of identity security but are increasingly supplemented by modern authentication methods.

**Policy Types:**

**Local Password Policies:**

- Applied to individual Windows machines (non-domain)
- Affects all local user accounts on the computer
- Configured through Local Group Policy Editor (gpedit.msc)
- Limited compared to domain-based policies

**Domain Password Policies:**

- Centrally managed through Active Directory Group Policy
- Applied across entire domains or organizational units
- More granular control and reporting capabilities
- Can implement Fine-Grained Password Policies for different user groups

**Core Password Policy Settings:**

**Password Complexity Requirements:**

- **Minimum Length:** 8-14 characters (current best practice: 12+ characters)
- **Complexity Rules:** Mix of uppercase, lowercase, numbers, and special characters
- **Password History:** Prevent reuse of previous 12-24 passwords
- **Minimum Age:** Prevent immediate password changes (typically 1 day)
- **Maximum Age:** Force periodic changes (trend moving away from mandatory changes)

**Account Lockout Policies:**

- **Lockout Threshold:** Number of failed attempts before lockout (3-5 attempts recommended)
- **Lockout Duration:** Time account remains locked (15-30 minutes)
- **Reset Counter:** Time before failed attempt counter resets (15-30 minutes)

**Modern Password Protection:**

**Azure AD Password Protection:**

- **Global Banned Passwords:** Microsoft-maintained list of compromised passwords
- **Custom Banned Lists:** Organization-specific forbidden passwords
- **Fuzzy Matching:** Detects variations of banned passwords
- **Hybrid Integration:** Extends protection to on-premises Active Directory

**Windows Hello Integration:**

- **Biometric Authentication:** Fingerprint, facial recognition, iris scanning
- **PIN Protection:** Device-specific numeric authentication
- **Security Keys:** FIDO2-compatible hardware tokens
- **Passwordless Experience:** Reduces reliance on traditional passwords

**Security Enhancements:**

**Breach Protection:**

- **Microsoft Defender for Identity:** Monitors for password-related attacks
- **Azure AD Identity Protection:** Risk-based conditional access
- **Leaked Credential Detection:** Alerts when organizational passwords found in breaches
- **Smart Lockout:** AI-powered protection against brute force attacks

**Monitoring and Compliance:**

- **Audit Logging:** Track password changes and failed authentications
- **Compliance Reporting:** Meet regulatory requirements (SOX, HIPAA, etc.)
- **Security Analytics:** Identify patterns in authentication failures
- **Incident Response:** Automated responses to suspicious activities

**Implementation Considerations:**

**User Experience Balance:**

- **Usability vs. Security:** Avoid overly restrictive policies that encourage workarounds
- **Help Desk Impact:** Complex policies increase support requests
- **Adoption Strategy:** Gradual implementation with user training
- **Exception Handling:** Process for legitimate business needs

**Technical Limitations:**

- **Application Compatibility:** Some legacy systems have password restrictions
- **Federation Challenges:** Consistent policies across hybrid environments
- **Mobile Devices:** Different capabilities for password enforcement
- **Service Accounts:** Special considerations for automated systems

**Access Locations:**

- **Local:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Domain:** Group Policy Management Console > Default Domain Policy
- **Azure AD:** Azure Portal > Azure Active Directory > Security > Authentication Methods
- **Microsoft 365:** Microsoft 365 Admin Center > Settings > Security & Privacy

## Network Management

### Windows Defender Firewall

**Overview:**
Windows Defender Firewall is a host-based, stateful firewall built into Windows that monitors and controls network traffic based on predetermined security rules. It provides the first line of defense against network-based attacks and unauthorized access attempts.

#### Core Functionality

**Traffic Control:**

- **Inbound Filtering:** Blocks unsolicited incoming connections by default
- **Outbound Filtering:** Optional control over applications accessing the network
- **Stateful Inspection:** Tracks connection states and allows return traffic for established connections
- **Protocol Support:** Handles TCP, UDP, ICMP, and other network protocols
- **Port Management:** Granular control over specific ports and services

#### Network Profiles

**Domain Profile:**

- Applied when connected to Active Directory domain networks
- Typically less restrictive due to trusted network environment
- Centrally managed through Group Policy
- Allows domain-related services and communications

**Private Profile:**

- Used for trusted home or work networks
- Moderate security settings balancing protection and functionality
- Allows network discovery and file sharing within trusted networks
- User-configurable with reasonable defaults

**Public Profile:**

- Most restrictive settings for untrusted networks (hotels, airports, cafes)
- Blocks most incoming connections and network discovery
- Prioritizes security over convenience
- Recommended for public Wi-Fi environments

#### Advanced Features:

**Rule Configuration:**

- **Application-based Rules:** Control specific programs' network access
- **Port-based Rules:** Allow/block specific TCP/UDP ports
- **IP Address Filtering:** Restrict access by source/destination addresses
- **Service-based Rules:** Control Windows services network activity
- **Custom Rules:** Complex filtering based on multiple criteria

**Security Enhancements:**

- **IPSec Integration:** Built-in support for encrypted communications
- **Connection Security Rules:** Authenticate and encrypt network traffic
- **Notification System:** Alerts for blocked applications and suspicious activity
- **Logging Capabilities:** Track allowed and blocked connections for analysis

#### Enterprise Management

**Group Policy Integration:**

- **Centralized Configuration:** Domain-wide firewall policy deployment
- **Profile Inheritance:** Automatic application based on network type
- **Rule Distribution:** Consistent security policies across organization
- **Compliance Monitoring:** Ensure firewall settings meet organizational standards

**Modern Management Tools:**

- **Windows Admin Center:** Web-based firewall management
- **PowerShell Cmdlets:** Scripted firewall configuration and automation
- **Microsoft Intune:** Cloud-based firewall policy management
- **System Center Configuration Manager:** Enterprise-scale deployment

#### Security Considerations

**Threat Protection:**

- **Malware Communication Blocking:** Prevents infected systems from communicating with command and control servers
- **Lateral Movement Prevention:** Limits attacker spread within networks
- **Data Exfiltration Protection:** Controls outbound traffic to prevent data theft
- **Remote Access Security:** Manages RDP, SSH, and other remote connections

**Common Attack Vectors:**

- **Application Exploitation:** Malware using legitimate applications to bypass firewall
- **Port Scanning:** Automated discovery of open services and vulnerabilities
- **Social Engineering:** Tricking users into creating firewall exceptions
- **Privilege Escalation:** Administrative access to modify firewall rules

#### Best Practices:

**Configuration Principles:**

- **Default Deny:** Block all traffic except explicitly allowed
- **Least Privilege:** Grant minimum necessary network access
- **Regular Review:** Periodically audit and clean up firewall rules
- **Application Whitelisting:** Prefer specific application rules over broad port openings

**Operational Guidelines:**

- **Monitor Logs:** Regular analysis of firewall activity for anomalies
- **User Education:** Train users on firewall notification responses
- **Exception Management:** Formal process for firewall rule requests
- **Incident Response:** Procedures for firewall-related security events

#### Limitations:

**Technical Constraints:**

- **Application Layer Protection:** Limited visibility into encrypted application traffic
- **Bypass Methods:** Legitimate applications can be exploited to circumvent rules
- **Performance Impact:** Extensive logging and complex rules can affect system performance
- **User Override:** Local administrators can modify or disable firewall settings

**Management Challenges:**

- **Rule Complexity:** Large numbers of rules can become difficult to manage
- **False Positives:** Legitimate applications may be incorrectly blocked
- **User Experience:** Overly restrictive settings can impact productivity
- **Legacy Applications:** Older software may require broad network access

**Access Methods:**

- **Windows Firewall with Advanced Security:** `wf.msc`
- **Settings App:** Settings > Update & Security > Windows Security > Firewall & network protection
- **Control Panel:** Control Panel > System and Security > Windows Defender Firewall
- **PowerShell:** `Get-NetFirewallRule`, `New-NetFirewallRule` cmdlets

**Monitoring and Troubleshooting:**

- **Event Viewer:** Windows Firewall log analysis
- **Performance Monitor:** Network and firewall performance metrics
- **Network Diagnostics:** Built-in troubleshooting tools
- **Third-party Tools:** Enhanced monitoring and management solutions

### Disabling Unused Network Devices in Microsoft Windows

**Purpose:**
Disabling unused network adapters reduces the attack surface by eliminating potential entry points for malicious traffic, prevents network conflicts and IP address conflicts, and improves system performance by reducing unnecessary driver overhead and background network services.

#### Security Benefits

- **Attack Surface Reduction:** Eliminates unused network interfaces that could be exploited
- **Information Disclosure Prevention:** Stops potential data leakage through inactive adapters
- **Network Isolation:** Prevents unintended network bridging between active and inactive interfaces
- **Compliance:** Meets security hardening guidelines that require disabling unnecessary services and hardware

#### Methods

**Device Manager:**

1. Right-click "This PC" > Properties > Device Manager
2. Expand "Network adapters"
3. Right-click unused adapter > "Disable device"
4. Confirm the action

**Network and Sharing Center:**

1. Control Panel > Network and Sharing Center
2. Click "Change adapter settings"
3. Right-click unused network connection > "Disable"

**PowerShell (Administrative):**

```powershell
# List network adapters
Get-NetAdapter
# Disable specific adapter
Disable-NetAdapter -Name "Adapter Name" -Confirm:$false
```

**Group Policy (Enterprise):**

- Computer Configuration > Administrative Templates > Network > Network Connections
- Configure policies to disable specific network adapter types

**Best Practice:** Regularly audit enabled network devices and disable any adapters not actively used for business purposes, while maintaining documentation of disabled devices for future reference and troubleshooting.

### SMB Protocol Summary

**What is SMB:**
Server Message Block (SMB) is a network communication protocol that enables file and printer sharing, inter-process communication, and network resource access between devices on a network. Originally developed by IBM and enhanced by Microsoft, SMB operates at the application layer and is fundamental to Windows networking, allowing users to read, write, and request services from network servers.

**SMB Versions:**

- **SMB 1.0/CIFS:** Legacy protocol with significant security vulnerabilities (deprecated)
- **SMB 2.0/2.1:** Improved performance and security (Windows Vista/7 era)
- **SMB 3.0:** Enhanced encryption and security features (Windows 8/Server 2012)
- **SMB 3.1.1:** Current version with advanced security and performance optimizations

#### Common SMB Security Hazards:

**Protocol Vulnerabilities:**

- **EternalBlue (MS17-010):** Critical vulnerability exploited by WannaCry ransomware
- **SMBGhost (CVE-2020-0796):** Memory corruption in SMB 3.1.1 compression
- **Man-in-the-Middle Attacks:** Unencrypted SMB traffic can be intercepted
- **Relay Attacks:** NTLM authentication can be relayed to compromise other systems

**Attack Vectors:**

- **Lateral Movement:** Attackers use SMB to spread across networks after initial compromise
- **Credential Harvesting:** SMB authentication can expose password hashes
- **Remote Code Execution:** Vulnerable SMB implementations allow arbitrary code execution
- **Denial of Service:** Malformed SMB packets can crash systems or services

**Network Reconnaissance:**

- **Share Enumeration:** Attackers discover accessible network shares and sensitive data
- **System Information Gathering:** SMB reveals system details and user accounts
- **Null Session Attacks:** Anonymous connections to gather network intelligence

**Security Benefits to Disabling SMB:**

- **Attack Surface Reduction:** Eliminates a major vector for network-based attacks
- **Malware Prevention:** Stops SMB-based malware propagation (ransomware, worms)
- **Data Protection:** Prevents unauthorized access to shared files and folders
- **Network Isolation:** Reduces risk of lateral movement during security incidents

**When to Disable SMB:**

- Standalone computers not requiring network file sharing
- Systems in high-security environments or DMZs
- Legacy systems running vulnerable SMB 1.0 implementations
- Internet-facing systems with no legitimate SMB requirements

#### Methods for Disabling SMB

**PowerShell Commands (Administrative):**

**Disable SMB Server:**

```powershell
# Disable SMB 1.0
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
# Disable SMB Server service
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
# Stop and disable Server service
Stop-Service -Name "Server" -Force
Set-Service -Name "Server" -StartupType Disabled
```

**Disable SMB Client:**

```powershell
# Disable SMB client
Set-SmbClientConfiguration -EnableSMB1Protocol $false -Force
# Disable Workstation service
Stop-Service -Name "Workstation" -Force
Set-Service -Name "Workstation" -StartupType Disabled
```

**Windows Features (GUI Method):**

1. Control Panel > Programs > Turn Windows features on or off
2. Uncheck "SMB 1.0/CIFS File Sharing Support"
3. Restart computer when prompted

**Registry Method:**

```cmd
# Disable SMB 1.0 via Registry
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f
```

**Group Policy (Enterprise):**

- Computer Configuration > Administrative Templates > Network > Lanman Server
- Set "Microsoft network server: Digitally sign communications (always)" to Enabled
- Configure "SMB Security Settings" policies

**Services Management:**

1. Run `services.msc`
2. Stop and disable "Server" service (SMB server functionality)
3. Stop and disable "Workstation" service (SMB client functionality)

**Verification Commands:**

```powershell
# Check SMB configuration
Get-SmbServerConfiguration | Select EnableSMB1Protocol
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
# Verify services status
Get-Service -Name "Server","Workstation"
```

**If SMB Must Remain Enabled:**

- **Update to SMB 3.1.1:** Ensure latest version with security enhancements
- **Enable SMB Encryption:** Force encryption for all SMB communications
- **Network Segmentation:** Isolate SMB traffic to trusted network segments
- **Access Controls:** Implement strict share permissions and authentication
- **Monitoring:** Deploy network monitoring for suspicious SMB activity

**Firewall Rules:**

```powershell
# Block SMB ports at firewall level
New-NetFirewallRule -DisplayName "Block SMB" -Direction Inbound -Protocol TCP -LocalPort 445,139 -Action Block
New-NetFirewallRule -DisplayName "Block SMB UDP" -Direction Inbound -Protocol UDP -LocalPort 137,138 -Action Block
```

**Considerations:**

- **Business Impact:** Ensure legitimate file sharing requirements are met through alternative methods
- **Application Dependencies:** Verify that critical applications don't rely on SMB functionality
- **Network Printing:** Consider impact on network printer access
- **Backup Systems:** Ensure backup solutions have alternative protocols available


## Application Management

## Storage Management

## Updating Windows

## Cheatsheet for Windows Hardening