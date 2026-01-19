# OWASP Zed Attack Proxy  

## Introduction  

completely open source and free
no premium version
no features are locked behind a paywall
no proprietary code  
automatically passively and actively scan a web application, build a sitemap, and discover vulnerabilities (a paid feature in Burp) 
passively build a website map with Spidering (a paid feature in Burp)
Unthrottled Intruder: You can bruteforce login pages within OWASP as fast as your machine and the web-server can handle (paid feature in Burp)
No need to forward individual requests through Burp: When doing manual attacks, having to change windows to send a request through the browser, and then forward in burp, can be tedious. OWASP handles both and you can just browse the site and OWASP will intercept automatically. This is NOT a feature in Burp.  

## Automated Scans

### Traditional Spider

a passive scan that enumerates links and directories of the website  
builds a website index without brute-forcing  
much quieter than a brute-force attack  
can net a login page or other juicy details  
not as comprehensive as a bruteforce  

### Ajax Spider

an add-on that integrates in ZAP a crawler of AJAX rich sites called Crawljax  
used in conjunction with the traditional spider for better results
uses your web browser and proxy  

### Zap Basic Configuration  

![Zap Basic](/images/zap-101.png)  

### Advanced Configurations

`Ctrl+Alt+O`  

![Scan Options](/images/zap-102.png)  

## Manual Scanning

### Set up the Proxy 

Tools > Options > Local Servers/Proxies  

![zap options](/images/zap-103.png)  

Address: 127.0.0.1
Port: 8080  

### Install ZAP Root CA Certificates

![Zap Root CA](/images/zap-104.png)  

Save the certificate to a local drive  

Import the certificate into FireFox  (or whatever)  

![import cert](/images/zap-105.png)  

### Update Firefox Network Connection Settings

Set HTTP Proxy, HTTPS Proxy, and SOCKS Host to 127.0.0.1

Set HTTP Proxy, HTTPS Proxy port to 8080, or the match set up in the ZAP Configuration  

Set the SOCKS proxy to 9050  

![Firefox Network Connection](/images/zap-106.png)  


## Scanning and Authenticated Web Application

Using DVWA as the tutorial,  

Log in as an authenticated user (admin:Password)

set the security level to "Low"  

![DVWA](/images/zap-107.png)  

### Authenticate ZAP

Identify the value of the authenticated PHPSESSION cookie.  

![Autentication Cookie](/images/zap-108.png)  

Press the green `+` to add the HTTP session tab  

![Session Tab](/images/zap-109.png)  

Identify the session matching the authenticated session and set that session to Active  

Conduct a new scan and review the significant increase in results  

## Brute Force Directories

Set up the Forced Browse options including the number of threads and a wordlist.  

![Forced Browse](/images/zap-110.png)  

Start the Forced Browse  

![Forced Browse Start](/images/zap-111.png)  

## Brute Force Web Login  

At the target login, attempt any credentials   (admin:test789)

![attempt1](/images/zap-112.png)  

Identify the request using the credentials and open the fuzz options  

![brute force 1](/images/zap-113.png)  

Highlight the password and add a wordlist to initiate the brute force attempt  

![wordlist](/images/zap-114.png) 

The correct word is likely the response with the largest body  

![password](/images/zap-115.png)  


