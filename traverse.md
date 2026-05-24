# Traverse

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

Bob is a security engineer at a firm and works closely with the software/DevOps team to develop a tourism web application. Once the website was moved from QA to Production, the team noticed that the website was getting hacked daily and wanted to know the exact reason. Bob consulted the blue team as well but has yet to be successful. Therefore, he finally enrolled in the Software Security pathway at THM to learn if he was doing something wrong.

Deploy the machine by clicking the Start Machine button on the top right. You can access the website by visiting the URL http://MACHINE_IP via your VPN connection or the AttackBox.

### Can you help Bob find the vulnerabilities and restore the website?

### What type of encoding is used by the hackers to obfuscate the JavaScript file?

- **Answer:** Hex

### What is the flag value after deobfuscating the file?

- directory listing is the only way

Logging is an important aspect. What is the name of the file containing email dumps?

- **Answer:** email_dumps.txt

The logs folder contains email logs and has a message for the software team lead. What is the name of the directory that Bob has created?

- **Answer:** Planning

### What is the key file for opening the directory that Bob has created for Mark?

- **Answer:** THM{100100111}

### What is the email address for ID 5 using the leaked API endpoint?

- **Answer:** john@traverse.com

### What is the ID for the user with admin privileges?

- **Answer:** 3

### What is the endpoint for logging in as the admin? Mention the last endpoint instead of the URL. For example, if the answer is URL is tryhackme.com/admin - Just write /admin.

- **Answer:** /realadmin

The attacker uploaded a web shell and renamed a file used for managing the server. Can you find the name of the web shell that the attacker has uploaded?

- **Answer:** thm_shell.php

### What is the name of the file renamed by the attacker for managing the web server?

- **Answer:** renamed_file_manager.php

### Can you use the file manager to restore the original website by removing the "FINALLY HACKED" message? What is the flag value after restoring the main website?

## Step 1: Review The Page Source

- contains links and directories

- two javascript files with comments that tell you they are important

- one contains hex, the answer to question 1.

## Step 2: Deobfuscate the hex

- use cyberchef:

""(function(){function doNothing(){}var n="DIRECTORY";var e="LISTING";var o="IS THE";var i="ONLY WAY";var f=null;var l=false;var d;if(f===null){console.log("Flag:"+n+" "+e+" "+o+" "+i);d=undefined}else if(typeof f==="undefined"){d=undefined}else{if(l){d=undefined}else{(function(){if(d){for(var n=0;n<10;n++){console.log("This code does nothing.")}doNothing()}else{doNothing()}})()}}})();"

## Step 3: Review directories

- "logs" directory is suggested in the html

- view the /logs/ found a file: email_dump.txt

## Step 4: Read Email Dump

- contains the api key

"

- From: Bob <bob@tourism.mht>

- To: Mark <mark@tourism.mht>

- Subject: API Credentials

Hey Mark,

Sorry I had to rush earlier for the holidays, but I have created the directory for you with all the required information for the API.

You loved SSDLC so much, I named the API folder under the name of the first phase of SSDLC.

This page is password protected and can only be opened through the key. THM{100100111}

See ya after the holidays

Bob.""

## Step 5: Log into the Planning folder

- password is: THM{100100111}

- Includes Base Instructions:

"

- Instructions:

- Base URL: MACHINE IP Address

- Endpoint: api/?customer_id=1

- HTTP Method: GET

- Parameters:

- {id}: The customer ID for retrieving customer information

- API Request:

- GET http://MACHINE IP/api/?customer_id=1

"

- Includes API responses:

"

{

- "data": {

- "id": "1",

- "name": "string",

- "email": "example@example.com",

- "password": "*****",

- "timestamp": "0000-00-00 00:00:00",

- "role": "user/admin",

- "loginURL": "https://example.com/loginURL",

- "isadmin": "boolean"

},

- "response_code": 200,

- "response_desc": "Success"

}

"

## Step 6: Craft API Requests

```bash
curl http://10.10.200.118/api/?customer_id=5
```

- found admin user

- id:3

- name: admin

- email: realadmin@traverse.com

- password:admin_key!!!

## Step 7: Visit /realadmin

- log in

- open "inpsector"

- the drop down has two programmed commands.

- changed "whoami" to "ls" and then executed the command on the website

## Step 8: Read the renamed_file_manager.php

- in the inspector, replaced "whoami" with "cat renamed_file_manager.php"

- found credentials

'Password', 'Username2' => 'Password2', ...)

$auth_users = array(

'admin' => '$2y$10$7I5BYtzKiWD7Gqip7ZoGvuN.nRb0EJAqJh8CZgRcHkNXZSQgTpFPu', //admin@123

'user' => '$2y$10$Fg6Dz8oH9fPoZ2jJan5tZuv6Z4Kp7avtQ9bDfrdRntXtPeiMAZyGO' //12345

);

// Readonly users

// e.g. array('users', 'guest', ...)

$readonly_users = array(

'user'

);

// Global readonly, including when auth is not being used

$global_readonly = false;

- couldn't log in as admin

- could log in as user

- final flag is in the index.php file… didn't really need to make any changes
