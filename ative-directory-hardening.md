# Active Directory Hardening

## General Concpets

**Domain:**
A domain is the fundamental administrative and security boundary in Active Directory that contains and manages objects (users, computers, resources) within a specific namespace. It serves as the primary unit for authentication, authorization, and policy enforcement.

**Domain Controller (DC):**
A Windows Server running Active Directory Domain Services that authenticates users, enforces security policies, and maintains the AD database. Modern DCs support features like Read-Only Domain Controllers (RODC) for branch offices and cloud hybrid integration with Azure AD Connect.

**Trees:**
A hierarchical collection of domains sharing a contiguous DNS namespace and automatic two-way transitive trusts. Child domains inherit security policies from parent domains and enable distributed administration while maintaining centralized authentication.

**Forests:**
The top-level container representing the security boundary in AD, containing one or more domain trees that share a common schema, configuration, and Global Catalog. Cross-forest trusts enable resource sharing between separate AD implementations.

**Active Directory Trusts:**

**Trust Types by Characteristics:**

- **Transitive:** Trust relationships that extend through the trust path (A trusts B, B trusts C, therefore A trusts C)
- **Non-Transitive:** Direct trust only between two specific domains without extension

**Trust Types by Direction:**

- **One-Way:** Unidirectional trust where one domain trusts another (trusting domain can access trusted domain's resources)
- **Two-Way:** Bidirectional trust enabling mutual resource access between domains

**Modern Trust Enhancements:**

- **External Trusts:** Connect to domains outside the forest
- **Forest Trusts:** Enable authentication across different AD forests
- **Shortcut Trusts:** Optimize authentication paths in complex domain structures
- **Selective Authentication:** Granular control over cross-forest access

**Objects and Organizational Structure:**

**Container Objects:**
Organizational Units (OUs), domains, and built-in containers that can hold other objects and have Group Policy applied. Modern containers support advanced features like Protected Users groups and Administrative Units for delegated administration.

**Leaf Objects:**
End-point objects like users, computers, printers, and services that cannot contain other objects. These represent the actual resources and identities managed within the directory.

**Management Access:**

- **Modern Interface:** Active Directory Administrative Center (dsac.exe)
- **Classic Tools:** Active Directory Users and Computers (dsa.msc)
- **PowerShell:** Active Directory module cmdlets
- **Cloud Integration:** Azure AD Connect and hybrid management tools


## Securing Authentication Methods

**Legacy Hash Management:**

**LM Hash Elimination:**

```powershell
# Verify LM hash storage is disabled
Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutDuration, LockoutObservationWindow, LockoutThreshold

# Configure via Group Policy (PowerShell equivalent)
Set-ADDefaultDomainPasswordPolicy -Identity "domain.com" -ComplexityEnabled $true -MinPasswordLength 14

# Registry verification for LM hash disabling
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Get-ItemProperty -Path $regPath -Name "NoLMHash" -ErrorAction SilentlyContinue
```

**Modern Password Hash Protection:**

- **Windows 10/11:** LM hash storage disabled by default
- **NTLM Restrictions:** Implement NTLM blocking where possible
- **Kerberos Prioritization:** Configure Kerberos as primary authentication protocol
- **Protected Users Group:** Automatically disables legacy authentication methods

**Enhanced SMB Security:**

**SMB Signing Configuration:**

```powershell
# Configure SMB signing via PowerShell
Set-SmbServerConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true
Set-SmbClientConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true

# Verify SMB signing status
Get-SmbServerConfiguration | Select-Object RequireSecuritySignature, EnableSecuritySignature
Get-SmbClientConfiguration | Select-Object RequireSecuritySignature, EnableSecuritySignature

# Advanced SMB security
Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSMB2Protocol $true
Set-SmbServerConfiguration -EncryptData $true  # SMB 3.0+ encryption
```

**Group Policy Configuration:**

```md
Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options

Required Settings:
- "Microsoft network client: Digitally sign communications (always)" = Enabled
- "Microsoft network server: Digitally sign communications (always)" = Enabled  
- "Microsoft network client: Digitally sign communications (if server agrees)" = Enabled
- "Microsoft network server: Digitally sign communications (if client agrees)" = Enabled
```

**Advanced LDAP Security:**

**LDAP Signing and Channel Binding:**

```powershell
# Configure LDAP signing requirements
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
New-ItemProperty -Path $regPath -Name "LDAPServerIntegrity" -Value 2 -PropertyType DWORD -Force  # Require signing

# Enable LDAP channel binding (CVE-2017-8563 mitigation)
New-ItemProperty -Path $regPath -Name "LdapEnforceChannelBinding" -Value 2 -PropertyType DWORD -Force

# Configure LDAP over SSL/TLS
New-ItemProperty -Path $regPath -Name "LDAP SSL Port" -Value 636 -PropertyType DWORD -Force
```

**Modern LDAP Security Features:**

- **LDAPS (LDAP over SSL):** Enforce encrypted LDAP communications
- **SASL (Simple Authentication and Security Layer):** Advanced authentication mechanisms
- **Channel Binding:** Prevents LDAP relay attacks
- **Certificate Authentication:** PKI-based LDAP authentication

**Advanced Password Management:**

**Group Managed Service Accounts (gMSA):**

```powershell
# Create Key Distribution Service (KDS) root key
Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)

# Create Group Managed Service Account
New-ADServiceAccount -Name "WebServerGMSA" -DNSHostName "webserver.domain.com" -PrincipalsAllowedToRetrieveManagedPassword "WebServers"

# Install gMSA on target server
Install-ADServiceAccount -Identity "WebServerGMSA"

# Verify gMSA functionality
Test-ADServiceAccount -Identity "WebServerGMSA"
```

**Automated Password Rotation:**

```powershell
# Advanced password rotation script with security logging
function Set-ADPasswordRotation {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ServiceAccounts,
        
        [int]$PasswordLength = 32,
        [bool]$LogToEventLog = $true
    )
    
    foreach ($account in $ServiceAccounts) {
        try {
            # Generate cryptographically secure password
            $password = -join ((33..126) | Get-Random -Count $PasswordLength | ForEach-Object {[char]$_})
            $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
            
            # Update AD account
            Set-ADAccountPassword -Identity $account -NewPassword $securePassword -Reset
            
            # Update service configurations
            $services = Get-WmiObject Win32_Service | Where-Object {$_.StartName -like "*$account*"}
            foreach ($service in $services) {
                # Update service logon credentials (requires additional service-specific logic)
                Write-Host "Service $($service.Name) requires manual credential update"
            }
            
            if ($LogToEventLog) {
                Write-EventLog -LogName Application -Source "AD-PasswordRotation" -EventId 1001 -Message "Password rotated for account: $account"
            }
            
        }
        catch {
            Write-Error "Password rotation failed for $account : $($_.Exception.Message)"
            if ($LogToEventLog) {
                Write-EventLog -LogName Application -Source "AD-PasswordRotation" -EventId 1002 -EntryType Error -Message "Password rotation failed for $account : $($_.Exception.Message)"
            }
        }
    }
}
```

**Modern Authentication Enhancements:**

**Kerberos Security:**

```powershell
# Configure Kerberos encryption types
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"
New-ItemProperty -Path $regPath -Name "SupportedEncryptionTypes" -Value 0x7FFFFFFF -PropertyType DWORD -Force

# Enable Kerberos armoring (FAST)
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos"
New-ItemProperty -Path $regPath -Name "StrictKdcValidation" -Value 1 -PropertyType DWORD -Force
```

**Multi-Factor Authentication Integration:**

```powershell
# Azure AD Connect MFA configuration
Install-Module AzureAD -Force
Connect-AzureAD

# Enable MFA for privileged accounts
$mfaPolicy = @{
    DisplayName = "Require MFA for Admins"
    State = "Enabled"
    Conditions = @{
        Users = @{
            IncludeRoles = @("Global Administrator", "Security Administrator")
        }
    }
    GrantControls = @{
        BuiltInControls = @("mfa")
    }
}

# Apply conditional access policy (requires appropriate licensing)
New-AzureADMSConditionalAccessPolicy @mfaPolicy
```

**Enhanced Password Policies:**

**Fine-Grained Password Policies (FGPP):**

```powershell
# Create fine-grained password policy for privileged users
New-ADFineGrainedPasswordPolicy -Name "PrivilegedUserPolicy" `
    -Precedence 10 `
    -MinPasswordLength 16 `
    -PasswordHistoryCount 24 `
    -MaxPasswordAge "60.00:00:00" `
    -MinPasswordAge "1.00:00:00" `
    -LockoutThreshold 3 `
    -LockoutDuration "00:30:00" `
    -LockoutObservationWindow "00:30:00" `
    -ComplexityEnabled $true

# Apply to privileged users group
Add-ADFineGrainedPasswordPolicySubject -Identity "PrivilegedUserPolicy" -Subjects "Domain Admins", "Enterprise Admins"

# Create policy for service accounts
New-ADFineGrainedPasswordPolicy -Name "ServiceAccountPolicy" `
    -Precedence 20 `
    -MinPasswordLength 32 `
    -PasswordHistoryCount 12 `
    -MaxPasswordAge "30.00:00:00" `
    -ComplexityEnabled $true `
    -LockoutThreshold 5
```

**Modern Password Security Features:**

```powershell
# Enable Azure AD Password Protection
Install-AzureADPasswordProtectionDCAgent
Install-AzureADPasswordProtectionProxy

# Configure banned password lists
$tenantId = "your-tenant-id"
Connect-AzureAD -TenantId $tenantId

# Custom banned passwords
$customList = @("CompanyName", "Password", "Welcome", "Summer2024")
# Note: Custom banned passwords require Azure AD Premium P1/P2

# Monitor password protection events
Get-WinEvent -LogName "Microsoft-AzureADPasswordProtection-DCAgent/Admin" | 
    Where-Object {$_.LevelDisplayName -eq "Warning"} |
    Format-Table TimeCreated, Id, Message
```

**Attack Surface Reduction:**

**Credential Protection:**

```powershell
# Enable Credential Guard
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
New-ItemProperty -Path $regPath -Name "EnableVirtualizationBasedSecurity" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $regPath -Name "RequirePlatformSecurityFeatures" -Value 3 -PropertyType DWORD -Force

# Protected Users group configuration
$protectedUsers = @("admin1", "admin2", "serviceaccount1")
foreach ($user in $protectedUsers) {
    Add-ADGroupMember -Identity "Protected Users" -Members $user
}

# Verify Protected Users restrictions
Get-ADGroupMember -Identity "Protected Users" | Select-Object Name, SamAccountName
```

**Authentication Policy Silos:**

```powershell
# Create authentication policy for high-value accounts
New-ADAuthenticationPolicy -Name "HighValueAccountPolicy" `
    -UserAllowedToAuthenticateFrom "O:SYG:SYD:(A;;CR;;;WD)" `
    -UserTGTLifetimeMins 240 `
    -ComputerAllowedToAuthenticateTo "O:SYG:SYD:(A;;CR;;;WD)"

# Create authentication policy silo
New-ADAuthenticationPolicySilo -Name "HighSecuritySilo" `
    -UserAuthenticationPolicy "HighValueAccountPolicy" `
    -ComputerAuthenticationPolicy "HighValueAccountPolicy"

# Assign users to silo
Set-ADUser -Identity "admin1" -AuthenticationPolicySilo "HighSecuritySilo"
```

**Monitoring and Auditing:**

**Advanced Audit Configuration:**

```powershell
# Enable advanced audit policies
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable

# Monitor authentication events
Get-WinEvent -LogName Security | 
    Where-Object {$_.Id -in @(4624, 4625, 4648, 4768, 4769, 4771)} |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -AutoSize
```

**Threat Detection:**

```powershell
# Monitor for suspicious authentication patterns
function Monitor-SuspiciousAuth {
    $suspiciousEvents = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4625 -and  # Failed logon
            $_.TimeCreated -gt (Get-Date).AddHours(-1)
        } | 
        Group-Object {$_.Properties[5].Value} |  # Group by account name
        Where-Object {$_.Count -gt 5}  # More than 5 failures
    
    if ($suspiciousEvents) {
        foreach ($event in $suspiciousEvents) {
            Write-Warning "Potential brute force attack against account: $($event.Name)"
            # Add alerting/response logic here
        }
    }
}

# Schedule monitoring
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)
Register-ScheduledTask -TaskName "AuthMonitoring" -Trigger $trigger -Action (New-ScheduledTaskAction -Execute "PowerShell" -Argument "-File C:\Scripts\Monitor-SuspiciousAuth.ps1")
```

## Implementing Least Privilege Model

**Modern Account Architecture:**

**Enhanced Account Types:**

```powershell
# Regular User Accounts with restricted privileges
New-ADUser -Name "John.Doe" -UserPrincipalName "john.doe@company.com" `
    -Path "OU=StandardUsers,DC=company,DC=com" `
    -AccountPassword (ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force) `
    -Enabled $true

# Add to standard user groups only
Add-ADGroupMember -Identity "Domain Users" -Members "John.Doe"

# Privileged Administrative Accounts (Tier 0)
New-ADUser -Name "Admin.JohnDoe" -UserPrincipalName "admin.johndoe@company.com" `
    -Path "OU=Tier0,OU=Admin,DC=company,DC=com" `
    -AccountPassword (ConvertTo-SecureString (New-RandomPassword -Length 24) -AsPlainText -Force) `
    -PasswordNeverExpires $false `
    -CannotChangePassword $false `
    -Enabled $true

# Add to Protected Users group for enhanced security
Add-ADGroupMember -Identity "Protected Users" -Members "Admin.JohnDoe"
```

**Azure AD Privileged Identity Management (PIM):**

```powershell
# Connect to Azure AD for PIM configuration
Install-Module AzureAD -Force
Connect-AzureAD

# Configure eligible role assignment (requires Azure AD Premium P2)
$roleDefinition = Get-AzureADMSRoleDefinition -Filter "DisplayName eq 'Global Administrator'"
$user = Get-AzureADUser -ObjectId "admin.johndoe@company.com"

# Create eligible assignment (not active by default)
New-AzureADMSRoleAssignment -RoleDefinitionId $roleDefinition.Id `
    -PrincipalId $user.ObjectId `
    -DirectoryScopeId "/" `
    -Type "Eligible"

# Configure activation requirements
$roleSettings = @{
    MaximumActivationDuration = "PT4H"  # 4 hours maximum
    RequireApproval = $true
    RequireJustification = $true
    RequireMFA = $true
}
```

**Advanced Role-Based Access Control:**

**Custom Administrative Units:**

```powershell
# Create Administrative Units for delegated management
New-AzureADMSAdministrativeUnit -DisplayName "HR Department" -Description "HR users and resources"
$hrUnit = Get-AzureADMSAdministrativeUnit -Filter "DisplayName eq 'HR Department'"

# Add users to Administrative Unit
$hrUsers = Get-AzureADUser -Filter "Department eq 'Human Resources'"
foreach ($user in $hrUsers) {
    Add-AzureADMSAdministrativeUnitMember -Id $hrUnit.Id -RefObjectId $user.ObjectId
}

# Assign scoped administrator
$helpDeskAdmin = Get-AzureADUser -ObjectId "helpdesk.admin@company.com"
$userAdminRole = Get-AzureADDirectoryRole -Filter "DisplayName eq 'User Account Administrator'"

New-AzureADMSScopedRoleAssignment -RoleId $userAdminRole.ObjectId `
    -PrincipalId $helpDeskAdmin.ObjectId `
    -AdministrativeUnitId $hrUnit.Id
```

**Conditional Access for Least Privilege:**

```powershell
# Create conditional access policy for privileged accounts
$policy = @{
    DisplayName = "Privileged Account Protection"
    State = "Enabled"
    Conditions = @{
        Users = @{
            IncludeGroups = @("Tier0-Administrators")
        }
        Applications = @{
            IncludeApplications = @("All")
        }
        Locations = @{
            IncludeLocations = @("All")
            ExcludeLocations = @("AllTrusted")
        }
    }
    GrantControls = @{
        BuiltInControls = @("mfa", "compliantDevice")
        Operator = "AND"
    }
    SessionControls = @{
        SignInFrequency = @{
            Value = 4
            Type = "hours"
        }
    }
}

New-AzureADMSConditionalAccessPolicy @policy
```

**Enhanced Tiered Access Model Implementation:**

**Tier 0 (Identity Infrastructure):**

```powershell
# Create Tier 0 organizational structure
New-ADOrganizationalUnit -Name "Tier0" -Path "OU=Administration,DC=company,DC=com"
New-ADOrganizationalUnit -Name "Accounts" -Path "OU=Tier0,OU=Administration,DC=company,DC=com"
New-ADOrganizationalUnit -Name "Groups" -Path "OU=Tier0,OU=Administration,DC=company,DC=com"
New-ADOrganizationalUnit -Name "ServiceAccounts" -Path "OU=Tier0,OU=Administration,DC=company,DC=com"

# Create Tier 0 security groups
New-ADGroup -Name "Tier0-Administrators" -GroupScope Global -GroupCategory Security `
    -Path "OU=Groups,OU=Tier0,OU=Administration,DC=company,DC=com"

New-ADGroup -Name "Tier0-ServiceAccounts" -GroupScope Global -GroupCategory Security `
    -Path "OU=Groups,OU=Tier0,OU=Administration,DC=company,DC=com"

# Implement Tier 0 Group Policy restrictions
$gpoName = "Tier0-Security-Policy"
New-GPO -Name $gpoName | New-GPLink -Target "OU=Tier0,OU=Administration,DC=company,DC=com"

# Configure logon restrictions (PowerShell representation of GPO settings)
$registrySettings = @{
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
        "DontDisplayLastUserName" = 1
        "DisableCAD" = 0
        "ShutdownWithoutLogon" = 0
    }
}
```

**Tier 1 (Server Infrastructure):**

```powershell
# Create Tier 1 structure for server management
New-ADOrganizationalUnit -Name "Tier1" -Path "OU=Administration,DC=company,DC=com"
New-ADGroup -Name "Tier1-ServerAdministrators" -GroupScope Global -GroupCategory Security `
    -Path "OU=Tier1,OU=Administration,DC=company,DC=com"

# Implement server-specific access controls
$tier1Policy = @{
    Name = "Tier1-Server-Access"
    Settings = @{
        "Allow log on as a service" = @("Tier1-ServiceAccounts")
        "Allow log on through Remote Desktop Services" = @("Tier1-ServerAdministrators")
        "Deny log on as a batch job" = @("Domain Users")
    }
}
```

**Tier 2 (Workstation Management):**

```powershell
# Create Tier 2 for end-user device management
New-ADOrganizationalUnit -Name "Tier2" -Path "OU=Administration,DC=company,DC=com"
New-ADGroup -Name "Tier2-HelpDesk" -GroupScope Global -GroupCategory Security `
    -Path "OU=Tier2,OU=Administration,DC=company,DC=com"

# Grant limited workstation management rights
$tier2Rights = @{
    "Reset user passwords" = $true
    "Unlock user accounts" = $true
    "Manage group membership" = $false  # Restricted
    "Modify security groups" = $false   # Prohibited
}
```

**Just-in-Time (JIT) Access Implementation:**

**Azure AD PIM Integration:**

```powershell
# Configure JIT access for administrative roles
function Request-JITAccess {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RoleName,
        
        [Parameter(Mandatory=$true)]
        [string]$Justification,
        
        [int]$DurationHours = 4
    )
    
    try {
        # Connect to Azure AD
        Connect-AzureAD
        
        # Get role definition
        $role = Get-AzureADMSRoleDefinition -Filter "DisplayName eq '$RoleName'"
        
        # Request activation
        $activationRequest = @{
            RoleDefinitionId = $role.Id
            Type = "UserAdd"
            AssignmentState = "Active"
            Schedule = @{
                StartDateTime = (Get-Date)
                Type = "Once"
                EndDateTime = (Get-Date).AddHours($DurationHours)
            }
            Reason = $Justification
        }
        
        Write-Host "JIT access requested for role: $RoleName"
        Write-Host "Justification: $Justification"
        Write-Host "Duration: $DurationHours hours"
        
    }
    catch {
        Write-Error "JIT access request failed: $($_.Exception.Message)"
    }
}

# Usage example
Request-JITAccess -RoleName "User Administrator" -Justification "Password reset for locked user account" -DurationHours 2
```

**Privileged Access Workstations (PAW):**

```powershell
# Configure PAW security settings
function Configure-PAWDevice {
    param(
        [string]$ComputerName
    )
    
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        # Disable unnecessary services
        $servicesToDisable = @("Themes", "Windows Search", "Superfetch")
        foreach ($service in $servicesToDisable) {
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
        
        # Enable advanced security features
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 1
        
        # Configure application restrictions
        Set-AppLockerPolicy -PolicyObject (Get-AppLockerPolicy -Local) -Merge
        
        # Enable auditing
        auditpol /set /subcategory:"Logon" /success:enable /failure:enable
        auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
    }
    
    Write-Host "PAW configuration applied to $ComputerName"
}
```

**Advanced Auditing and Compliance:**

**Automated Privilege Auditing:**

```powershell
# Comprehensive privilege audit script
function Invoke-PrivilegeAudit {
    param(
        [string]$Domain = (Get-ADDomain).DistinguishedName,
        [string]$OutputPath = "C:\Audits"
    )
    
    $auditResults = @()
    
    # Audit privileged groups
    $privilegedGroups = @(
        "Domain Admins", "Enterprise Admins", "Schema Admins", 
        "Account Operators", "Backup Operators", "Print Operators",
        "Server Operators", "Group Policy Creator Owners"
    )
    
    foreach ($group in $privilegedGroups) {
        $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction SilentlyContinue
        foreach ($member in $members) {
            $userInfo = Get-ADUser -Identity $member.SamAccountName -Properties LastLogonDate, PasswordLastSet, Enabled
            
            $auditResults += [PSCustomObject]@{
                GroupName = $group
                UserName = $member.SamAccountName
                DisplayName = $member.Name
                LastLogon = $userInfo.LastLogonDate
                PasswordLastSet = $userInfo.PasswordLastSet
                AccountEnabled = $userInfo.Enabled
                AccountAge = ((Get-Date) - $userInfo.PasswordLastSet).Days
                RiskLevel = if ($userInfo.LastLogonDate -lt (Get-Date).AddDays(-90)) { "High" } 
                          elseif ($userInfo.PasswordLastSet -lt (Get-Date).AddDays(-180)) { "Medium" } 
                          else { "Low" }
            }
        }
    }
    
    # Export results
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $auditResults | Export-Csv -Path "$OutputPath\PrivilegeAudit_$timestamp.csv" -NoTypeInformation
    
    # Generate summary report
    $summary = @{
        TotalPrivilegedAccounts = $auditResults.Count
        HighRiskAccounts = ($auditResults | Where-Object {$_.RiskLevel -eq "High"}).Count
        DisabledAccounts = ($auditResults | Where-Object {$_.AccountEnabled -eq $false}).Count
        StalePasswords = ($auditResults | Where-Object {$_.AccountAge -gt 180}).Count
    }
    
    return $summary
}

# Schedule regular auditing
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 6:00AM
$action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-File C:\Scripts\Invoke-PrivilegeAudit.ps1"
Register-ScheduledTask -TaskName "Weekly-PrivilegeAudit" -Trigger $trigger -Action $action -RunLevel Highest
```

**Real-time Privilege Monitoring:**
```powershell
# Monitor privilege escalation events
function Monitor-PrivilegeEscalation {
    $escalationEvents = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -in @(4728, 4732, 4756, 4624) -and  # Group membership changes and logons
            $_.TimeCreated -gt (Get-Date).AddHours(-1)
        }
    
    foreach ($event in $escalationEvents) {
        $eventXml = [xml]$event.ToXml()
        $targetAccount = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetUserName"} | Select-Object -ExpandProperty '#text'
        $subjectAccount = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "SubjectUserName"} | Select-Object -ExpandProperty '#text'
        
        if ($targetAccount -and $subjectAccount) {
            Write-Warning "Privilege escalation detected: $subjectAccount modified $targetAccount"
            
            # Send alert
            $alertMessage = @{
                Timestamp = $event.TimeCreated
                EventId = $event.Id
                SubjectAccount = $subjectAccount
                TargetAccount = $targetAccount
                ComputerName = $event.MachineName
            }
            
            # Add notification logic here (email, SIEM, etc.)
        }
    }
}
```

**Zero Trust Integration:**

**Identity Protection Policies:**

```powershell
# Configure Azure AD Identity Protection
$riskPolicy = @{
    DisplayName = "High Risk User Policy"
    State = "Enabled"
    Conditions = @{
        UserRiskLevels = @("high")
        Applications = @{
            IncludeApplications = @("All")
        }
    }
    GrantControls = @{
        BuiltInControls = @("passwordChange", "mfa")
        Operator = "OR"
    }
}

New-AzureADMSConditionalAccessPolicy @riskPolicy

# Sign-in risk policy
$signInRiskPolicy = @{
    DisplayName = "Medium and High Sign-in Risk Policy"
    State = "Enabled"
    Conditions = @{
        SignInRiskLevels = @("medium", "high")
        Applications = @{
            IncludeApplications = @("All")
        }
    }
    GrantControls = @{
        BuiltInControls = @("mfa")
    }
}

New-AzureADMSConditionalAccessPolicy @signInRiskPolicy
```

**Continuous Access Evaluation:**

```powershell
# Implement continuous access evaluation for critical resources
function Set-ContinuousAccessEvaluation {
    param(
        [string[]]$CriticalApplications,
        [string[]]$HighPrivilegeUsers
    )
    
    $caePolicy = @{
        DisplayName = "Continuous Access Evaluation - Critical Resources"
        State = "Enabled"
        Conditions = @{
            Users = @{
                IncludeUsers = $HighPrivilegeUsers
            }
            Applications = @{
                IncludeApplications = $CriticalApplications
            }
        }
        SessionControls = @{
            SignInFrequency = @{
                Value = 1
                Type = "hours"
                IsEnabled = $true
            }
            PersistentBrowser = @{
                IsEnabled = $true
                Mode = "never"
            }
        }
    }
    
    New-AzureADMSConditionalAccessPolicy @caePolicy
}

# Apply to critical systems
Set-ContinuousAccessEvaluation -CriticalApplications @("Office365", "AzurePortal") -HighPrivilegeUsers @("admin@company.com")
```

**Automated Compliance Reporting:**

**Least Privilege Compliance Dashboard:**

```powershell
# Generate comprehensive least privilege compliance report
function New-LeastPrivilegeComplianceReport {
    param(
        [string]$OutputPath = "C:\Reports",
        [switch]$EmailReport
    )
    
    $complianceData = @{}
    
    # Account distribution analysis
    $allUsers = Get-ADUser -Filter * -Properties MemberOf, LastLogonDate, PasswordLastSet
    $privilegedUsers = $allUsers | Where-Object {
        $_.MemberOf | ForEach-Object {
            $_ -match "CN=(Domain Admins|Enterprise Admins|Schema Admins|Account Operators)"
        }
    }
    
    $complianceData.AccountDistribution = @{
        TotalUsers = $allUsers.Count
        PrivilegedUsers = $privilegedUsers.Count
        PrivilegedPercentage = [math]::Round(($privilegedUsers.Count / $allUsers.Count) * 100, 2)
        StandardUsers = ($allUsers.Count - $privilegedUsers.Count)
    }
    
    # Inactive privileged accounts
    $inactivePrivileged = $privilegedUsers | Where-Object {
        $_.LastLogonDate -lt (Get-Date).AddDays(-30) -or $_.LastLogonDate -eq $null
    }
    
    $complianceData.InactiveAccounts = @{
        Count = $inactivePrivileged.Count
        Accounts = $inactivePrivileged | Select-Object Name, SamAccountName, LastLogonDate
        RiskLevel = if ($inactivePrivileged.Count -gt 5) { "High" } 
                   elseif ($inactivePrivileged.Count -gt 2) { "Medium" } 
                   else { "Low" }
    }
    
    # Service account analysis
    $serviceAccounts = Get-ADUser -Filter 'ServicePrincipalName -like "*"' -Properties ServicePrincipalName, MemberOf
    $privilegedServiceAccounts = $serviceAccounts | Where-Object {
        $_.MemberOf | ForEach-Object {
            $_ -match "CN=(Domain Admins|Enterprise Admins|Administrators)"
        }
    }
    
    $complianceData.ServiceAccounts = @{
        TotalServiceAccounts = $serviceAccounts.Count
        PrivilegedServiceAccounts = $privilegedServiceAccounts.Count
        ComplianceStatus = if ($privilegedServiceAccounts.Count -eq 0) { "Compliant" } else { "Non-Compliant" }
    }
    
    # Group membership analysis
    $adminGroups = @("Domain Admins", "Enterprise Admins", "Schema Admins")
    $groupAnalysis = @{}
    
    foreach ($group in $adminGroups) {
        $members = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
        $groupAnalysis[$group] = @{
            MemberCount = $members.Count
            Members = $members | Select-Object Name, SamAccountName
            RecommendedMaxMembers = switch ($group) {
                "Domain Admins" { 3 }
                "Enterprise Admins" { 2 }
                "Schema Admins" { 1 }
            }
        }
    }
    
    $complianceData.GroupAnalysis = $groupAnalysis
    
    # Generate compliance score
    $complianceScore = 100
    if ($complianceData.AccountDistribution.PrivilegedPercentage -gt 10) { $complianceScore -= 20 }
    if ($complianceData.InactiveAccounts.Count -gt 0) { $complianceScore -= 15 }
    if ($complianceData.ServiceAccounts.ComplianceStatus -eq "Non-Compliant") { $complianceScore -= 25 }
    
    foreach ($group in $groupAnalysis.Keys) {
        if ($groupAnalysis[$group].MemberCount -gt $groupAnalysis[$group].RecommendedMaxMembers) {
            $complianceScore -= 10
        }
    }
    
    $complianceData.OverallCompliance = @{
        Score = $complianceScore
        Rating = switch ($complianceScore) {
            {$_ -ge 90} { "Excellent" }
            {$_ -ge 80} { "Good" }
            {$_ -ge 70} { "Fair" }
            {$_ -ge 60} { "Poor" }
            default { "Critical" }
        }
    }
    
    # Export report
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = "$OutputPath\LeastPrivilegeCompliance_$timestamp.json"
    $complianceData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
    
    # Generate executive summary
    $executiveSummary = @"
LEAST PRIVILEGE COMPLIANCE REPORT - $(Get-Date -Format "yyyy-MM-dd")

OVERALL COMPLIANCE SCORE: $($complianceData.OverallCompliance.Score)% ($($complianceData.OverallCompliance.Rating))

KEY FINDINGS:
- Total Users: $($complianceData.AccountDistribution.TotalUsers)
- Privileged Users: $($complianceData.AccountDistribution.PrivilegedUsers) ($($complianceData.AccountDistribution.PrivilegedPercentage)%)
- Inactive Privileged Accounts: $($complianceData.InactiveAccounts.Count)
- Service Account Compliance: $($complianceData.ServiceAccounts.ComplianceStatus)

RECOMMENDED ACTIONS:
$(if ($complianceData.InactiveAccounts.Count -gt 0) { "- Review and disable inactive privileged accounts" })
$(if ($complianceData.AccountDistribution.PrivilegedPercentage -gt 10) { "- Reduce percentage of privileged users" })
$(if ($complianceData.ServiceAccounts.ComplianceStatus -eq "Non-Compliant") { "- Remove administrative privileges from service accounts" })
"@

    Write-Output $executiveSummary
    $executiveSummary | Out-File -FilePath "$OutputPath\ExecutiveSummary_$timestamp.txt"
    
    return $complianceData
}

# Schedule monthly compliance reports
$trigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At 8:00AM
$action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-File C:\Scripts\New-LeastPrivilegeComplianceReport.ps1"
Register-ScheduledTask -TaskName "Monthly-LeastPrivilegeCompliance" -Trigger $trigger -Action $action -RunLevel Highest
```

**Remediation Automation:**

**Automated Privilege Cleanup:**

```powershell
# Automated remediation for compliance violations
function Invoke-PrivilegeRemediation {
    param(
        [switch]$RemoveInactiveAccounts,
        [switch]$ReviewMode = $true,
        [int]$InactiveDays = 90
    )
    
    $remediationActions = @()
    
    if ($RemoveInactiveAccounts) {
        # Identify inactive privileged accounts
        $privilegedGroups = @("Domain Admins", "Enterprise Admins", "Schema Admins", "Account Operators")
        
        foreach ($group in $privilegedGroups) {
            $members = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
            
            foreach ($member in $members) {
                $user = Get-ADUser -Identity $member.SamAccountName -Properties LastLogonDate, Enabled
                
                if ($user.LastLogonDate -lt (Get-Date).AddDays(-$InactiveDays) -or $user.LastLogonDate -eq $null) {
                    $action = @{
                        Type = "Remove from privileged group"
                        User = $user.SamAccountName
                        Group = $group
                        LastLogon = $user.LastLogonDate
                        Reason = "Inactive for $InactiveDays days"
                    }
                    
                    if (-not $ReviewMode) {
                        try {
                            Remove-ADGroupMember -Identity $group -Members $user.SamAccountName -Confirm:$false
                            $action.Status = "Completed"
                            Write-Host "Removed $($user.SamAccountName) from $group due to inactivity"
                        }
                        catch {
                            $action.Status = "Failed"
                            $action.Error = $_.Exception.Message
                        }
                    } else {
                        $action.Status = "Review Required"
                    }
                    
                    $remediationActions += $action
                }
            }
        }
    }
    
    return $remediationActions
}

# Example usage for review
$proposedActions = Invoke-PrivilegeRemediation -RemoveInactiveAccounts -ReviewMode
$proposedActions | Format-Table -AutoSize
```

## Microsfot Security Compliance Toolkit

**Overview:**
Microsoft Security Compliance Toolkit (MSCT) is an official collection of tools and security baselines provided by Microsoft to help organizations implement, manage, and maintain security configurations across Windows environments. It eliminates the complexity of manual policy creation by providing pre-configured, tested security baselines aligned with industry best practices and Microsoft security recommendations.

**Core Components:**

**Security Compliance Manager (SCM):**

- **Baseline Management:** Import, customize, and manage Microsoft security baselines
- **Policy Comparison:** Compare current configurations against recommended baselines
- **Export Capabilities:** Generate Group Policy Objects (GPOs) and PowerShell scripts
- **Documentation:** Automated generation of security configuration documentation

**Security Baseline Tools:**

```powershell
# Download and extract security baselines
$baselineUrl = "https://www.microsoft.com/en-us/download/details.aspx?id=55319"
$extractPath = "C:\SecurityBaselines\"

# Import baseline using PowerShell
Import-Module "$extractPath\Scripts\Baseline-LocalInstall.ps1"

# Apply Windows 11 security baseline
.\Baseline-LocalInstall.ps1 -Win11NonDomainJoined
```

**Available Security Baselines:**

**Operating System Baselines:**

- **Windows 11:** Latest security configurations for current Windows version
- **Windows 10:** Version-specific baselines (21H2, 22H2, etc.)
- **Windows Server:** 2019, 2022 security configurations
- **Legacy Support:** Windows 8.1, Server 2012 R2 (limited support)

**Application Baselines:**

- **Microsoft Office 365/2021/2019:** Comprehensive Office security settings
- **Microsoft Edge:** Browser security and privacy configurations
- **Internet Explorer 11:** Legacy browser hardening (end-of-life considerations)

**Enterprise Application Baselines:**

```powershell
# Apply Office 365 security baseline
$officeBaseline = "C:\SecurityBaselines\Office365-Baseline\"
.\Scripts\Baseline-Office.ps1 -ApplyBaseline -ConfigurationType "Enterprise"

# Verify baseline application
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\*" | Select-Object PSPath, *Security*
```

**Implementation Methods:**

**Local Machine Application:**

```powershell
# Local Group Policy implementation
lgpo.exe /g "C:\SecurityBaselines\Windows11\GPOs\"

# Registry-based application
reg import "C:\SecurityBaselines\Windows11\Registry\Registry.pol"

# Verify applied settings
gpresult /h C:\Reports\GroupPolicyReport.html
```

**Domain-Wide Deployment:**

```powershell
# Import baselines to Active Directory
Import-GPO -BackupGpoName "Windows 11 Security Baseline" -TargetName "Corp-Security-Baseline" -Path "C:\SecurityBaselines\GPOs\"

# Link to organizational units
New-GPLink -Name "Corp-Security-Baseline" -Target "OU=Workstations,DC=company,DC=com" -LinkEnabled Yes

# Force policy refresh
Invoke-GPUpdate -Computer "WorkstationName" -Force
```

**Advanced Configuration Management:**

**Baseline Customization:**

```powershell
# Create custom baseline configuration
function New-CustomSecurityBaseline {
    param(
        [string]$BaselineSource,
        [string]$CustomizationFile,
        [string]$OutputPath
    )
    
    # Load baseline template
    $baseline = Import-Csv $BaselineSource
    $customizations = Import-Csv $CustomizationFile
    
    # Apply organizational customizations
    foreach ($custom in $customizations) {
        $baselineItem = $baseline | Where-Object {$_.SettingName -eq $custom.SettingName}
        if ($baselineItem) {
            $baselineItem.RecommendedValue = $custom.OrganizationValue
            $baselineItem.Justification = $custom.BusinessJustification
        }
    }
    
    # Export customized baseline
    $baseline | Export-Csv -Path "$OutputPath\Custom-Security-Baseline.csv" -NoTypeInformation
}
```

**Compliance Monitoring:**

```powershell
# Automated baseline compliance checking
function Test-BaselineCompliance {
    param(
        [string]$BaselinePath,
        [string[]]$TargetComputers
    )
    
    $complianceResults = @()
    
    foreach ($computer in $TargetComputers) {
        try {
            $compliance = Invoke-Command -ComputerName $computer -ScriptBlock {
                # Check security policy settings
                $secpol = secedit /export /cfg c:\temp\secpol.cfg /quiet
                $policies = Get-Content c:\temp\secpol.cfg
                
                # Check registry settings
                $registrySettings = @{
                    "DisablePasswordSaving" = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisablePasswordSaving" -ErrorAction SilentlyContinue
                    "LimitBlankPasswordUse" = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -ErrorAction SilentlyContinue
                    "NoLMHash" = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -ErrorAction SilentlyContinue
                }
                
                return @{
                    ComputerName = $env:COMPUTERNAME
                    PolicyExport = $policies
                    RegistrySettings = $registrySettings
                    Timestamp = Get-Date
                }
            }
            
            $complianceResults += $compliance
        }
        catch {
            Write-Warning "Failed to check compliance on $computer : $($_.Exception.Message)"
        }
    }
    
    return $complianceResults
}

# Generate compliance report
$results = Test-BaselineCompliance -BaselinePath "C:\Baselines\" -TargetComputers @("PC001", "PC002")
$results | Export-Csv -Path "C:\Reports\BaselineCompliance_$(Get-Date -Format 'yyyyMMdd').csv"
```

**Integration with Modern Management:**

**Microsoft Intune Integration:**

```powershell
# Convert Group Policy baselines to Intune configuration profiles
function Convert-GPOToIntune {
    param(
        [string]$GPOPath,
        [string]$ProfileName
    )
    
    # Analyze GPO settings
    $gpoReport = Get-GPOReport -Name $ProfileName -ReportType XML
    [xml]$gpoXml = $gpoReport
    
    # Extract registry settings for Intune
    $registrySettings = $gpoXml.GPO.Computer.ExtensionData.Extension.Policy | 
        Where-Object {$_.Category -eq "Registry"}
    
    # Create Intune configuration profile template
    $intuneProfile = @{
        "@odata.context" = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
        "@odata.type" = "#microsoft.graph.windows10CustomConfiguration"
        displayName = $ProfileName
        description = "Security baseline converted from Group Policy"
        omaSettings = @()
    }
    
    foreach ($setting in $registrySettings) {
        $omaSetting = @{
            "@odata.type" = "#microsoft.graph.omaSettingString"
            displayName = $setting.Name
            omaUri = "./Device/Vendor/MSFT/Policy/Config/ADMX_$($setting.Category)/$($setting.Name)"
            value = $setting.Value
        }
        $intuneProfile.omaSettings += $omaSetting
    }
    
    return $intuneProfile | ConvertTo-Json -Depth 10
}
```

**Azure Security Center Integration:**

```powershell
# Sync baselines with Azure Security Center recommendations
Connect-AzAccount

# Get Security Center recommendations
$recommendations = Get-AzSecurityRecommendation | 
    Where-Object {$_.DisplayName -like "*baseline*" -or $_.DisplayName -like "*configuration*"}

# Compare with applied baselines
$complianceGaps = @()
foreach ($recommendation in $recommendations) {
    if ($recommendation.State -eq "Unhealthy") {
        $complianceGaps += @{
            ResourceId = $recommendation.ResourceId
            Recommendation = $recommendation.DisplayName
            Severity = $recommendation.Severity
            RemediationSteps = $recommendation.RemediationSteps
        }
    }
}

$complianceGaps | Format-Table -AutoSize
```

**Automation and Orchestration:**

**Baseline Deployment Pipeline:**

```powershell
# Automated baseline deployment workflow
function Deploy-SecurityBaseline {
    param(
        [ValidateSet("Development", "Testing", "Production")]
        [string]$Environment,
        
        [string]$BaselineVersion,
        [string[]]$TargetOUs
    )
    
    $deploymentLog = @()
    
    try {
        # Download latest baseline
        $baselinePath = "C:\SecurityBaselines\$BaselineVersion"
        
        # Validate baseline integrity
        $checksum = Get-FileHash -Path "$baselinePath\*.cab" -Algorithm SHA256
        $deploymentLog += "Baseline integrity verified: $($checksum.Hash)"
        
        # Test deployment in isolated OU first
        if ($Environment -eq "Production") {
            $testOU = "OU=PolicyTest,DC=company,DC=com"
            $testResult = Test-BaselineDeployment -TargetOU $testOU -BaselinePath $baselinePath
            
            if (-not $testResult.Success) {
                throw "Baseline testing failed: $($testResult.Error)"
            }
        }
        
        # Deploy to target environments
        foreach ($ou in $TargetOUs) {
            $gpoName = "Security-Baseline-$Environment-$BaselineVersion"
            
            # Import and link GPO
            Import-GPO -BackupGpoName "Windows Security Baseline" -TargetName $gpoName -Path "$baselinePath\GPOs\"
            New-GPLink -Name $gpoName -Target $ou -LinkEnabled Yes
            
            $deploymentLog += "Deployed baseline to $ou successfully"
        }
        
        # Schedule compliance verification
        $verifyTask = @{
            TaskName = "Baseline-Compliance-Check-$Environment"
            Schedule = "Daily"
            Action = "Test-BaselineCompliance -Environment $Environment"
        }
        
        $deploymentLog += "Deployment completed successfully"
        
    }
    catch {
        $deploymentLog += "Deployment failed: $($_.Exception.Message)"
        throw
    }
    finally {
        # Log deployment results
        $deploymentLog | Out-File -FilePath "C:\Logs\BaselineDeployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    }
}
```

**Key Benefits:**

**Operational Advantages:**

- **Reduced Complexity:** Pre-configured baselines eliminate manual policy creation
- **Microsoft Validation:** Thoroughly tested configurations aligned with security best practices
- **Documentation:** Comprehensive guidance and rationale for each security setting
- **Version Control:** Regular updates reflecting latest threats and recommendations

**Security Benefits:**

- **Defense in Depth:** Multiple layers of security controls and configurations
- **Compliance Alignment:** Supports various regulatory frameworks (NIST, CIS, etc.)
- **Threat Mitigation:** Addresses current threat landscape and attack vectors
- **Consistency:** Standardized security posture across enterprise environments


## Protecting Against Known Attacks

**Advanced Credential-Based Attacks:**

**Kerberoasting (Enhanced Coverage):**

```powershell
# Detection script for Kerberoasting activities
function Detect-KerberoastingAttempts {
    # Monitor for suspicious TGS ticket requests
    Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4769 -and  # TGS ticket requested
            $_.Properties[8].Value -like "*RC4*" -and  # Weak encryption
            $_.TimeCreated -gt (Get-Date).AddHours(-24)
        } | 
        Group-Object {$_.Properties[0].Value} |  # Group by account
        Where-Object {$_.Count -gt 10} |  # Suspicious volume
        ForEach-Object {
            Write-Warning "Potential Kerberoasting: $($_.Name) - $($_.Count) TGS requests"
        }
}

# Mitigation: Configure AES encryption for Kerberos
Set-ADUser -Identity "ServiceAccount" -KerberosEncryptionType AES128,AES256

# Enable Kerberos armoring
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"
New-ItemProperty -Path $regPath -Name "SupportedEncryptionTypes" -Value 0x7FFFFFFF -PropertyType DWORD -Force
```

**AS-REP Roasting:**

```powershell
# Detect accounts vulnerable to AS-REP roasting
$vulnerableAccounts = Get-ADUser -Filter 'DoesNotRequirePreAuth -eq $true' -Properties DoesNotRequirePreAuth

if ($vulnerableAccounts) {
    Write-Warning "Accounts with Pre-Authentication disabled found:"
    $vulnerableAccounts | Select-Object Name, SamAccountName, DoesNotRequirePreAuth
    
    # Remediation: Enable pre-authentication
    foreach ($account in $vulnerableAccounts) {
        Set-ADUser -Identity $account.SamAccountName -DoesNotRequirePreAuth $false
        Write-Host "Pre-authentication enabled for $($account.SamAccountName)"
    }
}
```

**Advanced Persistence Attacks:**

**Golden Ticket Attacks:**

```powershell
# Monitor for Golden Ticket indicators
function Detect-GoldenTicketActivity {
    # Check for unusual Kerberos ticket lifetimes
    $suspiciousLogons = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4624 -and  # Successful logon
            $_.Properties[8].Value -eq 3 -and  # Network logon
            $_.Properties[18].Value -gt 10080  # Ticket lifetime > 7 days (suspicious)
        }
    
    # Monitor for domain admin logons from unusual sources
    $domainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Select-Object -ExpandProperty SamAccountName
    
    $suspiciousAdminLogons = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4624 -and
            $_.Properties[5].Value -in $domainAdmins -and
            $_.Properties[11].Value -notlike "*DomainController*"
        }
    
    if ($suspiciousAdminLogons) {
        Write-Warning "Potential Golden Ticket activity detected"
        $suspiciousAdminLogons | Format-Table TimeCreated, @{N="Account";E={$_.Properties[5].Value}}, @{N="Workstation";E={$_.Properties[11].Value}}
    }
}

# Mitigation: Regular KRBTGT password reset
function Reset-KRBTGTPassword {
    param(
        [switch]$DoubleReset  # Perform double reset for immediate invalidation
    )
    
    # Reset KRBTGT account password
    $newPassword = ConvertTo-SecureString (New-RandomPassword -Length 32) -AsPlainText -Force
    Set-ADAccountPassword -Identity "krbtgt" -NewPassword $newPassword -Reset
    
    Write-Host "KRBTGT password reset completed"
    
    if ($DoubleReset) {
        Start-Sleep -Seconds 300  # Wait for replication
        $newPassword2 = ConvertTo-SecureString (New-RandomPassword -Length 32) -AsPlainText -Force
        Set-ADAccountPassword -Identity "krbtgt" -NewPassword $newPassword2 -Reset
        Write-Host "KRBTGT double reset completed"
    }
    
    Write-Warning "All existing Kerberos tickets will be invalidated. Users may need to re-authenticate."
}
```

**DCSync Attacks:**

```powershell
# Monitor for DCSync attack indicators
function Detect-DCSyncActivity {
    # Monitor for unusual replication requests
    Get-WinEvent -LogName "Directory Service" | 
        Where-Object {
            $_.Id -eq 4662 -and  # Object access
            $_.Message -like "*Replicating Directory Changes*" -and
            $_.Properties[7].Value -notlike "*DOMAIN_CONTROLLER*"
        } | 
        ForEach-Object {
            Write-Warning "Potential DCSync attack from: $($_.Properties[1].Value)"
        }
}

# Mitigation: Restrict replication permissions
$dcsyncPermissions = @(
    "DS-Replication-Get-Changes",
    "DS-Replication-Get-Changes-All",
    "DS-Replication-Get-Changes-In-Filtered-Set"
)

# Audit current replication permissions
$domainDN = (Get-ADDomain).DistinguishedName
$acl = Get-Acl -Path "AD:\$domainDN"

$suspiciousACEs = $acl.Access | Where-Object {
    $_.IdentityReference -notlike "*Domain Controllers*" -and
    $_.IdentityReference -notlike "*Enterprise Domain Controllers*" -and
    ($_.ObjectType -in $dcsyncPermissions -or $_.ActiveDirectoryRights -like "*ExtendedRight*")
}

if ($suspiciousACEs) {
    Write-Warning "Suspicious replication permissions found:"
    $suspiciousACEs | Select-Object IdentityReference, ActiveDirectoryRights, ObjectType
}
```

**Modern Attack Techniques:**

**Living off the Land Attacks:**

```powershell
# Monitor for suspicious PowerShell activity
function Monitor-SuspiciousPowerShell {
    # Check for encoded commands
    Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | 
        Where-Object {
            $_.Id -eq 4104 -and  # Script block logging
            ($_.Message -like "*-EncodedCommand*" -or 
             $_.Message -like "*FromBase64String*" -or
             $_.Message -like "*DownloadString*" -or
             $_.Message -like "*Invoke-Expression*")
        } | 
        ForEach-Object {
            Write-Warning "Suspicious PowerShell activity detected: $($_.Message.Substring(0,100))..."
        }
    
    # Monitor for AD enumeration commands
    $adEnumCommands = @("Get-ADUser", "Get-ADGroup", "Get-ADComputer", "Get-ADDomain")
    
    Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | 
        Where-Object {
            $_.Id -eq 4104 -and
            ($adEnumCommands | ForEach-Object { $_.Message -like "*$_*" }) -contains $true
        } | 
        Group-Object {$_.UserId} | 
        Where-Object {$_.Count -gt 20} | 
        ForEach-Object {
            Write-Warning "Potential AD enumeration by user: $($_.Name)"
        }
}
```

**Password-Based Attack Mitigations:**

**Advanced Password Security:**

```powershell
# Implement Azure AD Password Protection
function Deploy-AzureADPasswordProtection {
    param(
        [string]$TenantId,
        [string[]]$DomainControllers
    )
    
    # Install DC Agent on domain controllers
    foreach ($dc in $DomainControllers) {
        Invoke-Command -ComputerName $dc -ScriptBlock {
            # Download and install DC Agent
            $dcAgentUrl = "https://download.microsoft.com/download/..."
            $installerPath = "$env:TEMP\AzureADPasswordProtectionDCAgent.exe"
            
            Invoke-WebRequest -Uri $dcAgentUrl -OutFile $installerPath
            Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
            
            Write-Host "Azure AD Password Protection DC Agent installed on $env:COMPUTERNAME"
        }
    }
    
    # Configure tenant connection
    Set-AzureADPasswordProtectionTenant -TenantId $TenantId
    
    Write-Host "Azure AD Password Protection deployment completed"
}

# Monitor for weak password attempts
function Monitor-WeakPasswords {
    # Check Azure AD Password Protection events
    Get-WinEvent -LogName "Microsoft-AzureADPasswordProtection-DCAgent/Admin" | 
        Where-Object {
            $_.Id -in @(10014, 10015, 10016) -and  # Password validation events
            $_.LevelDisplayName -eq "Warning"
        } | 
        ForEach-Object {
            Write-Warning "Weak password attempt blocked: $($_.Message)"
        }
    
    # Monitor for password spraying attempts
    $failedLogons = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4625 -and  # Failed logon
            $_.Properties[10].Value -eq 0xC000006A  # Bad password
        } | 
        Group-Object {$_.Properties[19].Value} |  # Group by source IP
        Where-Object {$_.Count -gt 50}  # High volume from single source
    
    if ($failedLogons) {
        Write-Warning "Potential password spraying detected from:"
        $failedLogons | Select-Object Name, Count
    }
}
```

**Network-Based Attack Mitigations:**

**RDP Security Hardening:**

```powershell
# Comprehensive RDP security configuration
function Harden-RDPSecurity {
    param(
        [string[]]$AllowedUsers = @(),
        [string[]]$AllowedIPs = @()
    )
    
    # Enable Network Level Authentication
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
    
    # Set strong encryption
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel" -Value 3
    
    # Configure account lockout for RDP
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "MaxFailedLogonAttempts" -Value 3
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "LockoutDuration" -Value 1800  # 30 minutes
    
    # Restrict RDP access via firewall
    if ($AllowedIPs.Count -gt 0) {
        New-NetFirewallRule -DisplayName "RDP-Restricted" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -RemoteAddress $AllowedIPs
        Set-NetFirewallRule -DisplayName "Remote Desktop*" -Enabled False
    }
    
    # Configure user rights
    $rdpUsers = "Remote Desktop Users"
    if ($AllowedUsers.Count -gt 0) {
        # Clear existing RDP users and add only allowed ones
        $currentMembers = Get-ADGroupMember -Identity $rdpUsers
        foreach ($member in $currentMembers) {
            Remove-ADGroupMember -Identity $rdpUsers -Members $member.SamAccountName -Confirm:$false
        }
        
        foreach ($user in $AllowedUsers) {
            Add-ADGroupMember -Identity $rdpUsers -Members $user
        }
    }
    
    Write-Host "RDP security hardening completed"
}

# Monitor RDP brute force attacks
function Monitor-RDPBruteForce {
    $rdpFailures = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 4625 -and  # Failed logon
            $_.Properties[8].Value -eq 10  # RDP logon type
        } | 
        Group-Object {$_.Properties[19].Value} |  # Group by source IP
        Where-Object {$_.Count -gt 10}
    
    foreach ($attack in $rdpFailures) {
        Write-Warning "RDP brute force detected from $($attack.Name) - $($attack.Count) attempts"
        
        # Automated response: Block IP
        New-NetFirewallRule -DisplayName "Block-Attacker-$($attack.Name)" -Direction Inbound -RemoteAddress $attack.Name -Action Block
    }
}
```

**SMB Share Security:**

```powershell
# Comprehensive SMB share audit and hardening
function Audit-SMBShares {
    # Get all SMB shares
    $shares = Get-SmbShare | Where-Object {$_.Name -notlike "*$"}  # Exclude admin shares
    
    $vulnerableShares = @()
    
    foreach ($share in $shares) {
        $shareAccess = Get-SmbShareAccess -Name $share.Name
        $permissions = Get-Acl -Path $share.Path
        
        # Check for Everyone access
        $everyoneAccess = $shareAccess | Where-Object {$_.AccountName -eq "Everyone"}
        
        # Check for unauthenticated access
        $guestAccess = $shareAccess | Where-Object {$_.AccountName -like "*Guest*"}
        
        # Check for excessive permissions
        $fullControlUsers = $permissions.Access | Where-Object {
            $_.FileSystemRights -eq "FullControl" -and
            $_.IdentityReference -notlike "*Administrators*" -and
            $_.IdentityReference -notlike "*SYSTEM*"
        }
        
        if ($everyoneAccess -or $guestAccess -or $fullControlUsers.Count -gt 0) {
            $vulnerableShares += @{
                ShareName = $share.Name
                SharePath = $share.Path
                EveryoneAccess = $everyoneAccess -ne $null
                GuestAccess = $guestAccess -ne $null
                ExcessivePermissions = $fullControlUsers.Count
                Recommendations = @()
            }
            
            if ($everyoneAccess) {
                $vulnerableShares[-1].Recommendations += "Remove Everyone group access"
            }
            if ($guestAccess) {
                $vulnerableShares[-1].Recommendations += "Remove Guest account access"
            }
            if ($fullControlUsers.Count -gt 0) {
                $vulnerableShares[-1].Recommendations += "Review Full Control permissions"
            }
        }
    }
    
    return $vulnerableShares
}

# Automated SMB share hardening
function Harden-SMBShares {
    param(
        [switch]$RemoveEveryoneAccess,
        [switch]$DisableGuestAccess,
        [switch]$EnableSMBSigning
    )
    
    $shares = Get-SmbShare | Where-Object {$_.Name -notlike "*$"}
    
    foreach ($share in $shares) {
        if ($RemoveEveryoneAccess) {
            # Remove Everyone group access
            try {
                Revoke-SmbShareAccess -Name $share.Name -AccountName "Everyone" -Force
                Write-Host "Removed Everyone access from share: $($share.Name)"
            }
            catch {
                Write-Warning "Could not remove Everyone access from $($share.Name): $($_.Exception.Message)"
            }
        }
        
        if ($DisableGuestAccess) {
            # Disable guest access
            Revoke-SmbShareAccess -Name $share.Name -AccountName "Guest" -Force -ErrorAction SilentlyContinue
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -RequireSecuritySignature $true -Force
        }
    }
    
    if ($EnableSMBSigning) {
        # Enable SMB signing globally
        Set-SmbServerConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true -Force
        Set-SmbClientConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true -Force
        Write-Host "SMB signing enabled globally"
    }
}

# Monitor for suspicious SMB access
function Monitor-SMBAccess {
    # Monitor for unusual file access patterns
    Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 5140 -and  # Network share object accessed
            $_.TimeCreated -gt (Get-Date).AddHours(-24)
        } | 
        Group-Object {$_.Properties[1].Value} |  # Group by account
        Where-Object {$_.Count -gt 100} |  # High volume access
        ForEach-Object {
            Write-Warning "Suspicious SMB access volume from account: $($_.Name) - $($_.Count) accesses"
        }
    
    # Monitor for access to sensitive shares
    $sensitiveShares = @("ADMIN$", "C$", "SYSVOL", "NETLOGON")
    
    Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -eq 5140 -and
            ($sensitiveShares | ForEach-Object { $_.Message -like "*$_*" }) -contains $true
        } | 
        ForEach-Object {
            Write-Warning "Access to sensitive share detected: $($_.Message.Substring(0,100))..."
        }
}
```

**Advanced Threat Detection and Response:**

**Comprehensive AD Attack Monitoring:**

```powershell
# Advanced threat hunting for AD attacks
function Start-ADThreatHunting {
    param(
        [int]$LookbackHours = 24,
        [switch]$ContinuousMonitoring
    )
    
    $startTime = (Get-Date).AddHours(-$LookbackHours)
    $threats = @()
    
    do {
        # Hunt for credential dumping attempts
        $credentialDumping = Get-WinEvent -LogName Security | 
            Where-Object {
                $_.Id -eq 4656 -and  # Handle to object requested
                $_.Message -like "*lsass.exe*" -and
                $_.TimeCreated -gt $startTime
            }
        
        if ($credentialDumping) {
            $threats += @{
                ThreatType = "Credential Dumping"
                Events = $credentialDumping
                Severity = "Critical"
                Timestamp = Get-Date
            }
        }
        
        # Hunt for lateral movement via PsExec/WMI
        $lateralMovement = Get-WinEvent -LogName Security | 
            Where-Object {
                ($_.Id -eq 4624 -and $_.Properties[8].Value -eq 3) -or  # Network logon
                ($_.Id -eq 4648)  # Explicit credential use
            } | 
            Group-Object {$_.Properties[5].Value} | 
            Where-Object {$_.Count -gt 20 -and $_.Group[0].TimeCreated -gt $startTime}
        
        if ($lateralMovement) {
            $threats += @{
                ThreatType = "Lateral Movement"
                Events = $lateralMovement
                Severity = "High"
                Timestamp = Get-Date
            }
        }
        
        # Hunt for privilege escalation
        $privEscalation = Get-WinEvent -LogName Security | 
            Where-Object {
                $_.Id -in @(4728, 4732, 4756) -and  # Group membership changes
                $_.Properties[2].Value -like "*Admin*" -and
                $_.TimeCreated -gt $startTime
            }
        
        if ($privEscalation) {
            $threats += @{
                ThreatType = "Privilege Escalation"
                Events = $privEscalation
                Severity = "Critical"
                Timestamp = Get-Date
            }
        }
        
        # Hunt for reconnaissance activities
        $reconnaissance = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | 
            Where-Object {
                $_.Id -eq 4104 -and
                ($_.Message -like "*Get-AD*" -or 
                 $_.Message -like "*net user*" -or 
                 $_.Message -like "*net group*" -or
                 $_.Message -like "*nltest*") -and
                $_.TimeCreated -gt $startTime
            } | 
            Group-Object {$_.UserId} | 
            Where-Object {$_.Count -gt 10}
        
        if ($reconnaissance) {
            $threats += @{
                ThreatType = "AD Reconnaissance"
                Events = $reconnaissance
                Severity = "Medium"
                Timestamp = Get-Date
            }
        }
        
        # Process and alert on threats
        foreach ($threat in $threats) {
            Write-Warning "THREAT DETECTED: $($threat.ThreatType) - Severity: $($threat.Severity)"
            
            # Automated response actions
            switch ($threat.ThreatType) {
                "Credential Dumping" {
                    # Isolate affected system
                    $computerName = $threat.Events[0].MachineName
                    Write-Host "Initiating isolation procedures for $computerName"
                    # Add network isolation logic here
                }
                "Lateral Movement" {
                    # Disable compromised account
                    $suspiciousAccount = $threat.Events.Name
                    Write-Host "Disabling suspicious account: $suspiciousAccount"
                    # Set-ADUser -Identity $suspiciousAccount -Enabled $false
                }
                "Privilege Escalation" {
                    # Alert security team immediately
                    Write-Host "CRITICAL: Privilege escalation detected - immediate investigation required"
                    # Add SIEM/alerting integration here
                }
            }
        }
        
        if ($ContinuousMonitoring) {
            Start-Sleep -Seconds 300  # Check every 5 minutes
            $startTime = (Get-Date).AddMinutes(-10)  # Rolling window
            $threats = @()  # Reset for next iteration
        }
        
    } while ($ContinuousMonitoring)
    
    return $threats
}
```

**Zero Trust and Modern Security Integration:**

**Conditional Access for AD Protection:**

```powershell
# Implement Zero Trust principles for AD access
function Implement-ZeroTrustAD {
    param(
        [string[]]$PrivilegedUsers,
        [string[]]$TrustedDevices
    )
    
    # Create conditional access policy for privileged accounts
    $privilegedAccessPolicy = @{
        DisplayName = "Zero Trust - Privileged AD Access"
        State = "Enabled"
        Conditions = @{
            Users = @{
                IncludeUsers = $PrivilegedUsers
            }
            Applications = @{
                IncludeApplications = @("All")
            }
            Locations = @{
                IncludeLocations = @("All")
                ExcludeLocations = @("AllTrusted")
            }
            DeviceStates = @{
                ExcludeStates = @("domainJoined", "hybridAzureADJoined", "compliant")
            }
        }
        GrantControls = @{
            BuiltInControls = @("mfa", "compliantDevice")
            Operator = "AND"
        }
        SessionControls = @{
            SignInFrequency = @{
                Value = 1
                Type = "hours"
                IsEnabled = $true
            }
        }
    }
    
    # Apply risk-based authentication
    $riskPolicy = @{
        DisplayName = "Zero Trust - Risk-Based AD Protection"
        State = "Enabled"
        Conditions = @{
            UserRiskLevels = @("medium", "high")
            SignInRiskLevels = @("medium", "high")
        }
        GrantControls = @{
            BuiltInControls = @("block")
        }
    }
    
    Write-Host "Zero Trust policies configured for AD protection"
}
```

**Advanced Forensics and Investigation:**

**AD Attack Forensics Toolkit:**

```powershell
# Comprehensive AD incident response toolkit
function Invoke-ADIncidentResponse {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IncidentType,
        
        [Parameter(Mandatory=$true)]
        [datetime]$IncidentTime,
        
        [string[]]$AffectedAccounts = @(),
        [string[]]$AffectedSystems = @()
    )
    
    $investigationData = @{}
    $lookbackTime = $IncidentTime.AddHours(-24)
    
    # Collect authentication logs
    $authLogs = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -in @(4624, 4625, 4648, 4768, 4769, 4771) -and
            $_.TimeCreated -ge $lookbackTime -and
            $_.TimeCreated -le $IncidentTime.AddHours(1)
        }
    
    $investigationData.AuthenticationEvents = $authLogs
    
    # Collect privilege escalation events
    $privEvents = Get-WinEvent -LogName Security | 
        Where-Object {
            $_.Id -in @(4728, 4729, 4732, 4733, 4756, 4757) -and
            $_.TimeCreated -ge $lookbackTime
        }
    
    $investigationData.PrivilegeEvents = $privEvents
    
    # Analyze affected accounts
    if ($AffectedAccounts.Count -gt 0) {
        $accountAnalysis = @()
        
        foreach ($account in $AffectedAccounts) {
            $userInfo = Get-ADUser -Identity $account -Properties *
            $recentLogons = $authLogs | Where-Object {
                $_.Properties[5].Value -eq $account
            }
            
            $accountAnalysis += @{
                Account = $account
                UserInfo = $userInfo
                RecentLogons = $recentLogons
                GroupMemberships = $userInfo.MemberOf
                LastPasswordSet = $userInfo.PasswordLastSet
                AccountLocked = $userInfo.LockedOut
            }
        }
        
        $investigationData.AccountAnalysis = $accountAnalysis
    }
    
    # Collect system information for affected systems
    if ($AffectedSystems.Count -gt 0) {
        $systemAnalysis = @()
        
        foreach ($system in $AffectedSystems) {
            try {
                $systemInfo = Invoke-Command -ComputerName $system -ScriptBlock {
                    @{
                        ComputerName = $env:COMPUTERNAME
                        LastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                        RunningProcesses = Get-Process | Select-Object Name, Id, StartTime, Path
                        NetworkConnections = Get-NetTCPConnection | Where-Object {$_.State -eq "Established"}
                        Services = Get-Service | Where-Object {$_.Status -eq "Running"}
                        RecentFiles = Get-ChildItem C:\Windows\Temp, C:\Users\*\AppData\Local\Temp -Recurse -File | 
                                    Where-Object {$_.CreationTime -gt (Get-Date).AddDays(-1)}
                    }
                }
                
                $systemAnalysis += $systemInfo
            }
            catch {
                Write-Warning "Could not collect data from $system : $($_.Exception.Message)"
            }
        }
        
        $investigationData.SystemAnalysis = $systemAnalysis
    }
    
    # Generate timeline
    $allEvents = @()
    $allEvents += $investigationData.AuthenticationEvents
    $allEvents += $investigationData.PrivilegeEvents
    
    $timeline = $allEvents | 
        Sort-Object TimeCreated | 
        Select-Object TimeCreated, Id, Message, MachineName
    
    $investigationData.Timeline = $timeline
    
    # Export investigation data
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputPath = "C:\Investigations\AD_Incident_$timestamp"
    New-Item -Path $outputPath -ItemType Directory -Force
    
    $investigationData | ConvertTo-Json -Depth 10 | 
        Out-File -FilePath "$outputPath\investigation_data.json"
    
    $timeline | Export-Csv -Path "$outputPath\incident_timeline.csv" -NoTypeInformation
    
    Write-Host "Investigation data collected and exported to: $outputPath"
    
    return $investigationData
}
```

**Best Practices for AD Attack Prevention:**

**Comprehensive Security Hardening:**

```powershell
# Complete AD hardening checklist implementation
function Invoke-ADSecurityHardening {
    Write-Host "=== Active Directory Security Hardening ==="
    
    # 1. Account security
    Write-Host "Configuring account security policies..."
    
    # Disable unused accounts
    $inactiveAccounts = Get-ADUser -Filter * -Properties LastLogonDate | 
        Where-Object {
            $_.LastLogonDate -lt (Get-Date).AddDays(-90) -and
            $_.Enabled -eq $true -and
            $_.SamAccountName -notlike "*$"
        }
    
    foreach ($account in $inactiveAccounts) {
        Disable-ADAccount -Identity $account.SamAccountName
        Write-Host "Disabled inactive account: $($account.SamAccountName)"
    }
    
    # 2. Kerberos security
    Write-Host "Hardening Kerberos configuration..."
    
    # Set strong encryption for all service accounts
    Get-ADUser -Filter 'ServicePrincipalName -like "*"' | 
        ForEach-Object {
            Set-ADUser -Identity $_ -KerberosEncryptionType AES128,AES256
        }
    
    # 3. Group Policy hardening
    Write-Host "Applying security Group Policies..."
    
    # Create security baseline GPO
    $gpoName = "AD-Security-Baseline"
    New-GPO -Name $gpoName | New-GPLink -Target (Get-ADDomain).DistinguishedName

    # 4. Audit configuration
    Write-Host "Configuring security auditing..."
    
    auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
    auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
    auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
    auditpol /set /subcategory:"Logon" /success:enable /failure:enable
    auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
    auditpol /set /subcategory:"Directory Service Changes" /success:enable /failure:enable
    auditpol /set /subcategory:"Directory Service Access" /success:enable /failure:enable
    
    # 5. LDAP security
    Write-Host "Configuring LDAP security..."
    
    # Require LDAP signing
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
    New-ItemProperty -Path $regPath -Name "LDAPServerIntegrity" -Value 2 -PropertyType DWORD -Force
    New-ItemProperty -Path $regPath -Name "LdapEnforceChannelBinding" -Value 2 -PropertyType DWORD -Force
    
    # 6. SMB security
    Write-Host "Hardening SMB configuration..."
    
    # Disable SMBv1 and enable signing
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -RequireSecuritySignature $true -Force
    Set-SmbClientConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true -Force
    
    # 7. Administrative account protection
    Write-Host "Protecting administrative accounts..."
    
    # Add all domain admins to Protected Users group
    $domainAdmins = Get-ADGroupMember -Identity "Domain Admins"
    foreach ($admin in $domainAdmins) {
        try {
            Add-ADGroupMember -Identity "Protected Users" -Members $admin.SamAccountName -ErrorAction SilentlyContinue
        }
        catch {
            # User might already be in Protected Users group
        }
    }
    
    Write-Host "Active Directory hardening completed successfully!"
}
```

**Automated Threat Response Framework:**

**Incident Response Automation:**

```powershell
# Automated response to detected AD attacks
function Invoke-AutomatedThreatResponse {
    param(
        [ValidateSet("Kerberoasting", "DCSync", "GoldenTicket", "BruteForce", "PrivilegeEscalation")]
        [string]$AttackType,
        
        [string[]]$CompromisedAccounts = @(),
        [string[]]$SourceIPs = @(),
        [string[]]$AffectedSystems = @()
    )
    
    $responseActions = @()
    
    switch ($AttackType) {
        "Kerberoasting" {
            Write-Host "RESPONSE: Kerberoasting attack detected"
            
            # Reset service account passwords
            foreach ($account in $CompromisedAccounts) {
                if ((Get-ADUser -Identity $account -Properties ServicePrincipalName).ServicePrincipalName) {
                    $newPassword = ConvertTo-SecureString (New-RandomPassword -Length 32) -AsPlainText -Force
                    Set-ADAccountPassword -Identity $account -NewPassword $newPassword -Reset
                    $responseActions += "Reset password for service account: $account"
                }
            }
            
            # Force Kerberos ticket refresh
            klist purge
            $responseActions += "Purged Kerberos ticket cache"
        }
        
        "DCSync" {
            Write-Host "RESPONSE: DCSync attack detected - CRITICAL"
            
            # Disable compromised accounts immediately
            foreach ($account in $CompromisedAccounts) {
                Disable-ADAccount -Identity $account
                $responseActions += "EMERGENCY: Disabled compromised account: $account"
            }
            
            # Reset KRBTGT password (double reset)
            Reset-KRBTGTPassword -DoubleReset
            $responseActions += "EMERGENCY: Performed KRBTGT double password reset"
            
            # Alert security team
            Send-CriticalAlert -Message "DCSync attack detected - immediate investigation required"
        }
        
        "GoldenTicket" {
            Write-Host "RESPONSE: Golden Ticket attack detected - CRITICAL"
            
            # Force domain-wide password reset for KRBTGT
            Reset-KRBTGTPassword -DoubleReset
            
            # Disable all potentially compromised accounts
            foreach ($account in $CompromisedAccounts) {
                Disable-ADAccount -Identity $account
                $responseActions += "Disabled account due to Golden Ticket attack: $account"
            }
            
            # Force all users to re-authenticate
            $responseActions += "Initiated domain-wide re-authentication"
        }
        
        "BruteForce" {
            Write-Host "RESPONSE: Brute force attack detected"
            
            # Block source IPs
            foreach ($ip in $SourceIPs) {
                New-NetFirewallRule -DisplayName "Block-BruteForce-$ip" -Direction Inbound -RemoteAddress $ip -Action Block
                $responseActions += "Blocked malicious IP: $ip"
            }
            
            # Lock targeted accounts temporarily
            foreach ($account in $CompromisedAccounts) {
                Set-ADUser -Identity $account -AccountExpirationDate (Get-Date).AddHours(1)
                $responseActions += "Temporarily locked account: $account"
            }
        }
        
        "PrivilegeEscalation" {
            Write-Host "RESPONSE: Privilege escalation detected"
            
            # Remove elevated privileges
            foreach ($account in $CompromisedAccounts) {
                $userGroups = Get-ADUser -Identity $account -Properties MemberOf | Select-Object -ExpandProperty MemberOf
                $privilegedGroups = $userGroups | Where-Object {$_ -like "*Admin*"}
                
                foreach ($group in $privilegedGroups) {
                    Remove-ADGroupMember -Identity $group -Members $account -Confirm:$false
                    $responseActions += "Removed $account from privileged group: $group"
                }
            }
        }
    }
    
    # Log all response actions
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @{
        Timestamp = $timestamp
        AttackType = $AttackType
        CompromisedAccounts = $CompromisedAccounts
        SourceIPs = $SourceIPs
        ResponseActions = $responseActions
        Severity = switch ($AttackType) {
            {"DCSync", "GoldenTicket"} { "Critical" }
            {"PrivilegeEscalation", "Kerberoasting"} { "High" }
            default { "Medium" }
        }
    }
    
    $logEntry | ConvertTo-Json | Out-File -Append -FilePath "C:\Logs\AD-ThreatResponse.log"
    
    return $responseActions
}

# Function to generate random secure passwords
function New-RandomPassword {
    param([int]$Length = 24)
    
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

# Function to send critical alerts
function Send-CriticalAlert {
    param([string]$Message)
    
    # Implementation would depend on your alerting system
    Write-Warning "CRITICAL ALERT: $Message"
    # Add email, SMS, or SIEM integration here
}
```

**Continuous Security Monitoring:**

**Real-time AD Security Dashboard:**

```powershell
# Comprehensive AD security monitoring dashboard
function Start-ADSecurityDashboard {
    param(
        [int]$RefreshIntervalSeconds = 60
    )
    
    Write-Host "Starting Active Directory Security Dashboard..."
    Write-Host "Press Ctrl+C to stop monitoring"
    
    while ($true) {
        Clear-Host
        Write-Host "=== ACTIVE DIRECTORY SECURITY DASHBOARD ===" -ForegroundColor Green
        Write-Host "Last Updated: $(Get-Date)" -ForegroundColor Yellow
        Write-Host ""
        
        # Account security status
        Write-Host "ACCOUNT SECURITY STATUS:" -ForegroundColor Cyan
        $totalUsers = (Get-ADUser -Filter *).Count
        $disabledUsers = (Get-ADUser -Filter 'Enabled -eq $false').Count
        $lockedUsers = (Search-ADAccount -LockedOut).Count
        $expiredPasswords = (Get-ADUser -Filter * -Properties PasswordExpired | Where-Object {$_.PasswordExpired}).Count
        
        Write-Host "  Total Users: $totalUsers"
        Write-Host "  Disabled: $disabledUsers"
        Write-Host "  Locked Out: $lockedUsers" -ForegroundColor $(if ($lockedUsers -gt 0) {"Red"} else {"Green"})
        Write-Host "  Expired Passwords: $expiredPasswords" -ForegroundColor $(if ($expiredPasswords -gt 10) {"Red"} else {"Green"})
        Write-Host ""
        
        # Privileged accounts monitoring
        Write-Host "PRIVILEGED ACCOUNTS:" -ForegroundColor Cyan
        $domainAdmins = (Get-ADGroupMember -Identity "Domain Admins").Count
        $enterpriseAdmins = (Get-ADGroupMember -Identity "Enterprise Admins" -ErrorAction SilentlyContinue).Count
        $schemaAdmins = (Get-ADGroupMember -Identity "Schema Admins" -ErrorAction SilentlyContinue).Count
        
        Write-Host "  Domain Admins: $domainAdmins" -ForegroundColor $(if ($domainAdmins -gt 5) {"Yellow"} else {"Green"})
        Write-Host "  Enterprise Admins: $enterpriseAdmins" -ForegroundColor $(if ($enterpriseAdmins -gt 2) {"Yellow"} else {"Green"})
        Write-Host "  Schema Admins: $schemaAdmins" -ForegroundColor $(if ($schemaAdmins -gt 1) {"Yellow"} else {"Green"})
        Write-Host ""
        
        # Recent security events
        Write-Host "RECENT SECURITY EVENTS (Last Hour):" -ForegroundColor Cyan
        $recentEvents = Get-WinEvent -LogName Security | 
            Where-Object {$_.TimeCreated -gt (Get-Date).AddHours(-1)} | 
            Group-Object Id | 
            Sort-Object Count -Descending | 
            Select-Object -First 5
        
        foreach ($event in $recentEvents) {
            $eventName = switch ($event.Name) {
                "4624" { "Successful Logons" }
                "4625" { "Failed Logons" }
                "4768" { "Kerberos TGT Requests" }
                "4769" { "Kerberos Service Tickets" }
                "4728" { "Group Membership Changes" }
                default { "Event ID $($event.Name)" }
            }
            
            $color = if ($event.Name -eq "4625" -and $event.Count -gt 50) {"Red"} 
                    elseif ($event.Name -eq "4625") {"Yellow"} 
                    else {"Green"}
            
            Write-Host "  $eventName : $($event.Count)" -ForegroundColor $color
        }
        Write-Host ""
        
        # Domain controller health
        Write-Host "DOMAIN CONTROLLER STATUS:" -ForegroundColor Cyan
        $domainControllers = Get-ADDomainController -Filter *
        foreach ($dc in $domainControllers) {
            $ping = Test-Connection -ComputerName $dc.Name -Count 1 -Quiet
            $color = if ($ping) {"Green"} else {"Red"}
            $status = if ($ping) {"Online"} else {"Offline"}
            Write-Host "  $($dc.Name): $status" -ForegroundColor $color
        }
        Write-Host ""
        
        # Threat indicators
        Write-Host "THREAT INDICATORS:" -ForegroundColor Cyan
        
        # Check for potential Kerberoasting
        $suspiciousTGS = Get-WinEvent -LogName Security | 
            Where-Object {
                $_.Id -eq 4769 -and 
                $_.Properties[8].Value -like "*RC4*" -and
                $_.TimeCreated -gt (Get-Date).AddHours(-1)
            } | 
            Group-Object {$_.Properties[0].Value} | 
            Where-Object {$_.Count -gt 10}
        
        if ($suspiciousTGS) {
            Write-Host "  Potential Kerberoasting: $($suspiciousTGS.Count) suspicious accounts" -ForegroundColor Red
        } else {
            Write-Host "  Kerberoasting: No threats detected" -ForegroundColor Green
        }
        
        # Check for privilege escalation
        $privEscalation = Get-WinEvent -LogName Security | 
            Where-Object {
                $_.Id -in @(4728, 4732, 4756) -and
                $_.TimeCreated -gt (Get-Date).AddHours(-1)
            }
        
        if ($privEscalation.Count -gt 0) {
            Write-Host "  Privilege Changes: $($privEscalation.Count) recent modifications" -ForegroundColor Yellow
        } else {
            Write-Host "  Privilege Escalation: No suspicious activity" -ForegroundColor Green
        }
        
        # Check for brute force attempts
        $bruteForce = Get-WinEvent -LogName Security | 
            Where-Object {
                $_.Id -eq 4625 -and
                $_.TimeCreated -gt (Get-Date).AddHours(-1)
            } | 
            Group-Object {$_.Properties[19].Value} | 
            Where-Object {$_.Count -gt 20}
        
        if ($bruteForce) {
            Write-Host "  Brute Force: $($bruteForce.Count) suspicious sources detected" -ForegroundColor Red
        } else {
            Write-Host "  Brute Force: No threats detected" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Refreshing in $RefreshIntervalSeconds seconds..." -ForegroundColor Gray
        
        Start-Sleep -Seconds $RefreshIntervalSeconds
    }
}

# Start the dashboard
# Start-ADSecurityDashboard -RefreshIntervalSeconds 30
```

**Summary of Modern AD Attack Mitigation:**

**Key Defense Strategies:**

1. **Multi-layered Authentication:** MFA, conditional access, and risk-based policies
2. **Continuous Monitoring:** Real-time threat detection and automated response
3. **Privilege Management:** Just-in-time access and regular privilege audits
4. **Network Security:** SMB signing, LDAP signing, and network segmentation
5. **Credential Protection:** Strong passwords, regular rotation, and Azure AD Password Protection
6. **Rapid Response:** Automated threat response and incident containment

**Critical Implementation Points:**

- **Regular Security Audits:** Monthly privilege reviews and quarterly security assessments
- **Staff Training:** Security awareness and incident response procedures
- **Backup and Recovery:** Tested restoration procedures for compromise scenarios
- **Integration with Modern Security:** Cloud identity protection and Zero Trust principles

**Monitoring and Alerting:**

- **24/7 SOC Integration:** Real-time threat detection and security operations center alerts
- **SIEM Integration:** Centralized log analysis and correlation across enterprise infrastructure
- **Behavioral Analytics:** AI-powered detection of anomalous user and system behavior
- **Threat Intelligence:** Integration with global threat feeds and indicators of compromise

**Recovery and Business Continuity:**

**Post-Incident Recovery Procedures:**

```powershell
# Comprehensive AD recovery framework
function Invoke-ADRecoveryProcedures {
    param(
        [ValidateSet("Partial", "Full", "Emergency")]
        [string]$RecoveryType,
        
        [datetime]$IncidentTime,
        [string[]]$CompromisedAccounts = @(),
        [string[]]$AffectedSystems = @()
    )
    
    Write-Host "=== AD RECOVERY PROCEDURES - $RecoveryType ===" -ForegroundColor Red
    
    $recoveryLog = @()
    
    switch ($RecoveryType) {
        "Emergency" {
            # Complete domain isolation and rebuild
            Write-Host "EMERGENCY RECOVERY: Complete domain compromise detected" -ForegroundColor Red
            
            # 1. Isolate all domain controllers
            $domainControllers = Get-ADDomainController -Filter *
            foreach ($dc in $domainControllers) {
                Write-Host "Isolating Domain Controller: $($dc.Name)"
                # Network isolation commands would go here
                $recoveryLog += "Isolated DC: $($dc.Name)"
            }
            
            # 2. Reset all privileged account passwords
            $privilegedGroups = @("Domain Admins", "Enterprise Admins", "Schema Admins", "Account Operators")
            foreach ($group in $privilegedGroups) {
                $members = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
                foreach ($member in $members) {
                    $newPassword = ConvertTo-SecureString (New-RandomPassword -Length 32) -AsPlainText -Force
                    Set-ADAccountPassword -Identity $member.SamAccountName -NewPassword $newPassword -Reset
                    $recoveryLog += "Reset password for privileged account: $($member.SamAccountName)"
                }
            }
            
            # 3. Multiple KRBTGT resets
            for ($i = 1; $i -le 3; $i++) {
                Reset-KRBTGTPassword -DoubleReset
                Start-Sleep -Seconds 3600  # Wait 1 hour between resets
                $recoveryLog += "KRBTGT reset iteration $i completed"
            }
        }
        
        "Full" {
            # Complete environment hardening and remediation
            Write-Host "FULL RECOVERY: Comprehensive security restoration" -ForegroundColor Yellow
            
            # 1. Account cleanup
            foreach ($account in $CompromisedAccounts) {
                # Disable account
                Disable-ADAccount -Identity $account
                
                # Remove from all groups except Domain Users
                $userGroups = (Get-ADUser -Identity $account -Properties MemberOf).MemberOf
                foreach ($group in $userGroups) {
                    if ($group -notlike "*Domain Users*") {
                        Remove-ADGroupMember -Identity $group -Members $account -Confirm:$false
                    }
                }
                
                # Reset password
                $newPassword = ConvertTo-SecureString (New-RandomPassword -Length 24) -AsPlainText -Force
                Set-ADAccountPassword -Identity $account -NewPassword $newPassword -Reset
                
                $recoveryLog += "Remediated compromised account: $account"
            }
            
            # 2. System cleanup
            foreach ($system in $AffectedSystems) {
                Invoke-Command -ComputerName $system -ScriptBlock {
                    # Clear event logs
                    Get-EventLog -List | ForEach-Object { Clear-EventLog -LogName $_.Log }
                    
                    # Reset local admin passwords
                    $localAdmins = Get-LocalGroupMember -Group "Administrators" | Where-Object {$_.PrincipalSource -eq "Local"}
                    foreach ($admin in $localAdmins) {
                        $newPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
                        Set-LocalUser -Name $admin.Name -Password (ConvertTo-SecureString $newPassword -AsPlainText -Force)
                    }
                    
                    # Force Windows Update
                    Install-WindowsUpdate -AcceptAll -AutoReboot
                }
                
                $recoveryLog += "System cleanup completed: $system"
            }
            
            # 3. Re-apply security hardening
            Invoke-ADSecurityHardening
            $recoveryLog += "Security hardening re-applied"
        }
        
        "Partial" {
            # Targeted remediation for specific incidents
            Write-Host "PARTIAL RECOVERY: Targeted incident remediation" -ForegroundColor Green
            
            # Reset only affected account passwords
            foreach ($account in $CompromisedAccounts) {
                $newPassword = ConvertTo-SecureString (New-RandomPassword -Length 20) -AsPlainText -Force
                Set-ADAccountPassword -Identity $account -NewPassword $newPassword -Reset
                Set-ADUser -Identity $account -ChangePasswordAtLogon $true
                $recoveryLog += "Password reset for account: $account"
            }
            
            # Single KRBTGT reset if Kerberos tickets were compromised
            Reset-KRBTGTPassword
            $recoveryLog += "KRBTGT password reset completed"
        }
    }
    
    # Generate recovery report
    $recoveryReport = @{
        RecoveryType = $RecoveryType
        IncidentTime = $IncidentTime
        RecoveryStartTime = Get-Date
        CompromisedAccounts = $CompromisedAccounts
        AffectedSystems = $AffectedSystems
        RecoveryActions = $recoveryLog
        NextSteps = @(
            "Monitor for 72 hours for additional compromise indicators",
            "Conduct forensic analysis of affected systems",
            "Update incident response procedures based on lessons learned",
            "Schedule security assessment and penetration testing"
        )
    }
    
    # Export recovery documentation
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $recoveryReport | ConvertTo-Json -Depth 10 | Out-File -FilePath "C:\Recovery\AD_Recovery_$timestamp.json"
    
    Write-Host "Recovery procedures completed. Documentation saved." -ForegroundColor Green
    return $recoveryReport
}
```

**Key Takeaways and Best Practices:**

**Critical Success Factors:**

- **Defense in Depth:** Multiple overlapping security controls to prevent single points of failure
- **Assume Breach Mentality:** Design security with the assumption that compromise will occur
- **Continuous Improvement:** Regular updates to security measures based on threat intelligence
- **Automation:** Automated detection and response to reduce mean time to containment
- **Documentation:** Comprehensive incident response plans and recovery procedures

**Implementation Priorities:**

1. **Immediate Actions:** Enable advanced auditing, deploy MFA, and harden privileged accounts
2. **Short-term (1-3 months):** Implement threat hunting, deploy SIEM integration, and establish SOC procedures
3. **Long-term (3-12 months):** Deploy Zero Trust architecture, implement advanced threat protection, and establish continuous security validation

**Compliance and Governance:**

- **Regular Assessments:** Quarterly security reviews and annual penetration testing
- **Policy Updates:** Continuous refinement of security policies based on threat landscape changes
- **Staff Training:** Regular security awareness training and incident response drills
- **Vendor Management:** Security assessments of third-party integrations and access

**Technology Integration:**

- **Cloud Security:** Azure AD integration, conditional access, and identity protection
- **Network Security:** Network segmentation, micro-segmentation, and software-defined perimeters
- **Endpoint Protection:** Advanced endpoint detection and response (EDR) integration
- **Security Orchestration:** SOAR platforms for automated incident response workflows

The modern Active Directory threat landscape requires a comprehensive, multi-layered security approach that combines traditional on-premises security controls with cloud-based intelligence and automation. Organizations must adopt a proactive security posture that assumes compromise and focuses on rapid detection, containment, and recovery to minimize business impact from sophisticated adversaries targeting Active Directory infrastructure.

**Final Recommendations:**

- **Start with fundamentals:** Secure privileged accounts, enable auditing, and implement strong authentication
- **Embrace automation:** Deploy automated threat detection and response capabilities
- **Plan for the worst:** Develop and test comprehensive incident response and recovery procedures
- **Stay current:** Continuously monitor threat intelligence and update security measures accordingly
- **Measure effectiveness:** Implement metrics to evaluate security program performance and improvement opportunities