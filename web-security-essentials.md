# Web Security Essentials

## Web Infrastructure

### Components

Application: The code, images, styles, and icons that dictate how the website looks and functions.  
Web Server: This component hosts the application. It listens for requests and returns a response to the user.  
Host Machine: The underlying operating system,  or Windows, that runs the web server and the application.  

### Web Servers

Apache  
NGINX  
Internet information Services (IIS)  

## Protecting the Web

### Protecting Components

#### Protecting the System

- Strong authentication  
- Patch management 

#### Protecting the Application

Secure Coding Practices:  

- avoide insecure functiosn
- correct error handing
- removing sensitive information

#### Protecting the Web Server:

- Log web requests and access logs
- Use Integrated WAF to filter and block harmful traffic
- Use of Content Devliery network to reduce direct exposure to servers

#### Protecting the Host Machine  

- Lease Privilege for all services and users
- System Hardening
- Antivirus and endpoint protection

## Defensive Systems

### Content Delivery Network (CDN)

store and serve cached content from primary servers.  
reduces latency by putting content closer to the user  

**Security Benefits**  

- Masks the IP of the orignal server
- Ability to absorbe large amounts of traffice, reducing DDOS  
- Enforces TLS
- Uses integrated WAF

### Web Application Firewall

Inspects incoming traffice and blocks, logs potentially harmful requests  

**Cloud-Based** : Sits in front of web server. highly scalable
**Host-Based** : Sits on webserver, controls each application  
**Network-BAsed** : Physical or virtual appliance. Sits on the nettwork perimeter. Mostly enterprise level

