# Powershell

## Temp Setup

Username 	Administrator
Password 	BHN2UVw0Q
IP 	10.64.130.4 

## Powershell Basics

Object-oriented  

`:> Get-Command` : List Commands  

List of [pproved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5&viewFallbackFrom=powershell-7)  

### Basic Commands

#### Get-Help

`Get-Help <commandlet name>` : Information about the commandlet  
`Get-Help <commandlet name -examples` : examples showing the use of the commandlet  

#### Get-Command

`Get-Command <verb>-*` : Show commandlets beginning with a particular verb  
`Get-Command *-<noun>` : show commandlets ending with a specific noun

#### Select-Object

Choose specific properties from the output of a commandlet

```md

:> PS C:\Users\Administrator> Get-ChildItem | Select-Object -Property Mode, Name

Mode   Name
----   ----
d-r--- Contacts
d-r--- Desktop
d-r--- Documents
```

#### Where-Object

Filtering the output of a commandlet  

`Verb-Noun | Where-Object -Property PropertyName -operator Value`

`Verb-Noun | Where-Object {_.PropertyName -operator Value}`  

`-operator` is a list of [operators](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.5&viewFallbackFrom=powershell-6)  

    `Contains`: works when any item in the property value is an exacdt match for the specified value
    `EQ`: returns true when the property value is the same as the specified value
    `GT`: returns true when the property value is greater than the specified value  

```md
PS C:\Users\Administrator> Get-Service | Where-Object -Property Status -eq Stopped

Status   Name               DisplayName
------   ----               -----------
Stopped  AJRouter           AllJoyn Router Service
Stopped  ALG                Application Layer Gateway Service
Stopped  AppIDSvc           Application Identity
Stopped  AppMgmt            Application Management
```

#### Sort-Object

`Verb-Noun` | `Sort-Object`  

```md
PS C:\Users\Administrator> Get-Service | Where-Object -Property Status -eq Stopped

Status   Name               DisplayName
------   ----               -----------
Stopped  AJRouter           AllJoyn Router Service
Stopped  ALG                Application Layer Gateway Service
Stopped  AppIDSvc           Application Identity
Stopped  AppMgmt            Application Management
```

#### Get-Location

Show the current working directory  

#### Invoke-WebRequest

Get content from a webpage on the internet (curl)  

### Enumeration

`:> get-localuser` : list local users  

`:> get-localuser | select-object name, SID` : list local users by name and SID  

`:> get-localuser | select-object name, SID, passwordrequired` : list local users and the name and SID values, as well as the value of of the property that indicates the use is required to reset the password.  

`:> get-localgroup` : list the local security groups

`:> get-adgroup` : list active directory groups  

`:> get-netipaddress` : Show the IP address configuration  

`:> get-nettcpconnection` : show number of listening tcp connections  

`:> get-hotfix | measures-object`  : get the list of applied patches and then count the number of applied patches  

`:> get-childitem` : list files and folders within a file system drive

`:> get-childitem -Recurse -Include *.txt` : recursively examine the files and folders in a system directory and list only those files with a .txt file extension  

`:> Get-Childitem -Recurse -Path C:\ -ErrorAction SilentlyContinue | Select-String "API_KEY"` : recursively search for any file containing a paricular string  (API_KEY), suppress error notifications  

`:> Get-Process` : List the running processes  

#### Basic Scripting

```powershell
$system_ports = Get-NetTCPConnection -State Listen
$text_port = Get-Content -Path C:\Users\Administrator\Desktop\ports.txt

foreach ($port in $text_port){
    if($port -in $system_ports.LocalPort){
        echo $port
    }
}
---


