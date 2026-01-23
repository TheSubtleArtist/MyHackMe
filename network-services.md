# Network Services  

Learn about, then enumerate and exploit a variety of network services and misconfigurations.

## SMB

Server Message Block Protocol
client-server communication protocol
known as a response-request protocol: transmits multiple messages between the client and server to establish a connection
used for sharing access to files, printers, serial ports and other resources on a network
Clients connect to servers using TCP/IP (actually NetBIOS over TCP/IP as specified in RFC1001 and RFC1002), NetBEUI or IPX/SPX.

Servers make file systems and other resources (printers, named pipes, APIs) available to clients on the network. 

Once they have established a connection, clients can then send commands (SMBs) to the server that allow them to access shares, open files, read and write files

### Enumerate SMB

***Port Scanning***  

***Enum4Linux***  

Enumerates on both Windows and Linux  
Wrapper around Samba package tools
[Source](https://github.com/CiscoCXSecurity/enum4linux)

[Usage](https://labs.portcullis.co.uk/tools/enum4linux/)  

### Exploit SMB with SMBClient

`:> smbclient //<IP>/<Share> -U <username> -p <port>`  

## Telnet

connect to and execute commands on a remote machine that's hosting a telnet server.  
sends all messages in clear text and has no specific security mechanisms  
connect : `:> telnet <IP> <port>`  

### Enumerate Telnet

***Port Scanning***

### Exploiting Telnet  

credential brute forcing  

reverse shells

## FTP

A typical FTP session operates using two channels:

- a command (sometimes called the control) channel
- a data channel 

In an Active FTP connection, the client opens a port and listens. The server is required to actively connect to it.  
In a Passive FTP connection, the server opens a port and listens (passively) and the client connects to it.  

### Enumerating FTP 

Port scanning  

### Exploiting FTP  

Hydra password cracking tool  

## Powerview

Post-exploitation and persistence tool  

powershell script from [Powershell Empire](https://www.powershellempire.com/)  

used for enumerating a domain after achieving access  

### Enumeration with Powerview 

[Cheatsheet] (https://gist.github.com/HarmJ0y/184f9822b195c52dd50c379ed3117993)  

`:> powershell -ep bypass` : start powershell and bypass execution policy  

`:> . .\<path>\PowerView.ps1` : start powerview, not a required space between the first `.` and the second `.`

`:> get-NetUser | select cn` : enumerate domain users

```md
PS C:\Users\Administrator> Get-NetUser | select cn

cn
--
Administrator
Guest
krbtgt
Machine-1
Admin2
Machine-2
SQL Service
POST{P0W3RV13W_FTW}
sshd
```

`:> Get-NetGroup -GroupName *admin*` : Enumerate domain groups

```md
Administrators 
Hyper-V Administrators
Storage Replica Administrators
Schema Admins
Enterprise Admins
Domain Admins 
Key Admins
Enterprise Key Admins
DnsAdmins
```

## Bloodhound

Post-exploitation and persistence tool  

graphical interface that allows you to visually map out the network  

[Documentation](https://github.com/SpecterOps/bloodHound-docs)

Often used in conjunction with [SharpHound](https://docs.taegis.secureworks.com/detectors/sharphound/)  

### Install Bloodhound on the Attacking device

`:> apt-get install bloodhound` 

`:> neo4j console`  

![Neo4J Console](/images/bloodhound-101.png)  
![Logged In](/images/bloodhound-102.png)  


### Run SharpHound on the victim Device

`PS:> powershell -ep bypass`  
`PS:> . .\<path>\SharpHoud.ps1`  
`PS:> Invoke-Bloodhound -CollectionMethod All -Domain CONTROLLER.local -ZipFileName loot.zip`  

![Sharphound Complete](images/bloodhound-103.png)  

Transfer the zip file to the attacking device.  

![scp](/images/bloodhound-104)

### Run Bloodhound on the Attacking device 

`:> bloodhound --no-sandbox`  

Unzip and Import the loot.zip file  

![unizpped](/images/bloodhound-105.png)

Drag and drop the files onto the interface  

![import](images/bloodhound-106.png)  

## Mimikatz

Post-exploitation and persistence tool  


## Server Manager

Post-exploitation and persistence tool  
