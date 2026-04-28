# Detecting Web Attacks

## -Client-Side Attacks

abuse of vulllnerabilities in browsers  
social-engineering used to trick users into 'unsafe' actions  
permits access to accounts and theft of sensitive information  

- credentials stored in password vaults or browser extensions
- use of iframes to steal data from active sessions  

### SOC Limitations  

No tools to see inside the user's browser  

### Common Client-Side Attacks  

#### Cross-Scripting (XSS)

most common  
malicious script run in a trusted website and executed in the browser  
Used to steal cookies and session data  

#### Cross-Site Request Forgery (CSRF)

attacker forces browser to send unauthroized requests on behalf of the trusted user  

could be used to initiate bank transfers  

#### Clickjacking

Attackers overlay invisible elements on top of legitimate content
Users click on what they see and execute what is unseen  
Nearly unlimited potential for malicious activity  

## SErver-Side Attacks

Exploit vulnerabilities within a web server, application code, or backend  
server logic, misconfigurations, input handling,  


## Log-Based Detection

## Network-Based Detection

## Web Application Firewall

