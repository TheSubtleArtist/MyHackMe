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

## Initiate the Exploit  

`:> pythohn3 50477.py -u http://10.201.126.242`
