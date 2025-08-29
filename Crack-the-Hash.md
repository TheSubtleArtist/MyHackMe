# [Crack The Hash](https://tryhackme.com/room/crackthehash)

## Table of Contents

### Task 1  

[Hash 1: MD5](#hash-1-48bb6e862e54f2a795ffc4e541caed4d)  
[Hash 2: SHA-1](#hash-2-cbfdac6008f9cab4083784cbd1874f76618d2a97)  
[Hash 3: SHA-256](#hash-3-1c8bfe8f801d79745c4631d09fff36c82aa37fc4cce4fc946683d7b336b63032)  
[Hash 4: Bcrypt](#hash-4-2y12dwt1bzj6pcyc3dy1fwz5ieeuznr71eenkjkulyptsgbx1h68wsrom)  
[Hash 5: MD4](#crackstation-5)  

### Task 2

[Hash 6: SHA-256](#hash-6-f09edcb1fcefc6dfb23dc3505a882655ff77375ed8aa2d1c13f640fccc2d0c85)  
[Hash 7: NTLM](#hash-7-1dfeca0c002ae40b8619ecf94819cc1b)  
[Hash 8: SHA-512-Ccrypt](#crackstation-8)  
[Hash 9: HMAC-SHA1](#hash-9-e5d8870e5bdd26602cab8dbe07a942c8669e56d6)  

### [Code Review - Identifying Hashes](#identifying-hashes)

This is the ultimate in beginner rooms. Hash cracking is a great way to start because there are plenty of online resources to help. Cracking hashes is deterministic. There is really only one correct answer and it helps to have some immediate success when you are new to the craft.

In this room, each hash only needs one solution. Maybe we can create some success for people by exploring the multiple tools available to perform the cracking.

This is the list of tools we will highlight for each hash.. when possible.

**CrackStation**  
[Crackstation](https://crackstation.net/)  is, fundamentally, a library of pre-cracked, unsalted hashes. A great go-to tool for the first step in any attempt to crack a hash.

**Hash-Identifier**  
[Hash-Identifier](https://gitlab.com/kalilinux/packages/hash-identifier) is a command line utility for identifying a user-supplied hash. There will be much more on this near the end.

**Hashcat**  
[Hashcat](https://hashcat.net/wiki/) is an advanced password recovery tool. The user cannot be afraid to continually reference the wiki and learn about the intricacies of Hashcat. It's capabilities are limited only by the user's curiosity. At the beginning level we are concerned with two hashcat options: Core Attack Mode (-a) and Hash Mode (-m). [Example hashes](https://hashcat.net/wiki/doku.php?id=example_hashes) show the hash-modes, especially if no other source has identified the hash. Visual identification might be the final resource.  
The basic hashcat command looks like:  
:> ````hashcat -a <attack-mode> -m <hash-mode> <hash> <path-to-wordlist>````  
In the event there is more than than one hash of the same type, they may each be placed on separate lines in a file.
![File With Multiple Hashes](/assets/hashcat01.png)  
The basic command changes only slightly:  
:> ````hashcat -a <attack-mode> -m <hash-mode> <path-to-file> <path-to-wordlist>````  

**The Wordlist**  
There are innumerable sources of wordlists. Kali Linux comes with wordlists pre-installed in /usr/share/wordlists/. This includes the most commonly used source 'rockyou.txt' which requires expansion prior to first used. In addition, very active Daniel Miessler maintains a considerable number of enriched security lists on Github [SecLists](https://github.com/danielmiessler/SecLists)

## Setup Notes  

Because of the potential level of repetition, each hash was placed in its own file in the Kali Linux environment. This facilitates some efficiencies when using the command line.  
![Screenshot of hash files inside the Kali Linux fs](/assets/kaliHashfiles.png) 
NOTE: There can be no invisible characters in the file. If there are, Hashcat will quit and indicate a "Token Length" error. 

## Task 1

### Hash 1: 48bb6e862e54f2a795ffc4e541caed4d

#### Crackstation

![Hash1](/assets/hash1.png)

#### Hash Identifier

The simplest use of hash identifier is as any other linux command.  
:>````hash-identifier 48bb6e862e54f2a795ffc4e541caed4d````  
gives us the same results as Crackstation.  

![Hash1 with hash-identifier](/assets/hash1-HI.png)  

#### Hashcat

The command:
:>````hashcat -m 0 -a 0 hash1 /usr/share/wordlists/rockyou.txt````
The result:
![Hash1 with Hashcat](/assets/hash1-HC.png)

### Hash 2: CBFDAC6008F9CAB4083784CBD1874F76618D2A97  

#### Crackstation

![Hash2](/assets/hash2.png)

#### Hash-Identifier

Try piping the contents of the hash2 file into the hash-identifer command.  
:>````cat hash2 | hash-identifier````  
This does not give a positive result.  
![Hash2 no piping](/assets/hash2-HI1.png)  
Try again with the standard method  
:>````hash-identifier CBFDAC6008F9CAB4083784CBD1874F76618D2A97````  
![Hash2 with hash-identifer](/assets/hash2-HI2.png)  

#### Hashcat

The command changes the hash-mode to 100, indicating the sha-1 hash:  
:>````hashcat -m 100 -a 0 hash2 /usr/share/wordlists/rockyou.txt````  
The result:  
![Hash2 with Hashcat](/assets/hash2-HC.png)  

### Hash 3: 1C8BFE8F801D79745C4631D09FFF36C82AA37FC4CCE4FC946683D7B336B63032

#### Crackstation

![Hash3](/assets/hash3.png)

#### Hash-Identifier

Users can start the hash-identifer before supply a hash.  
If there are multple hashes, hash-identifer continuse in an endless loop until it receives a keyboard interrupt.  
![Hash3 with hash-identifier](/assets/hash3-HI.png)  
Hash-Identifier provides the same result as Crackstation.

#### Hashcat

This one introduces a bit of complexity. Secure Hash Algorithms (SHA) is a family of hash algorithms. The SHA2 family includes 224, 256, 512, and some variations. When searching for the correct hash mode, the user must observe the formats of the various hashes that appear on the hashcat example pages. In this case, the correct mode is not sha-256, but sha2-256.  
:>````hashcat -m 1400 -a 0 hash3 /usr/share/wordlists/rockyou.txt````  
The result:  
![Hash3 with Hashcat](/assets/hash3-HC.png)  

### Hash 4: $2y$12$Dwt1BZj6pcyc3Dy1FWZ5ieeUznr71EeNkJkUlypTsgbX1H68wsRom

#### Crackstation

![Hash4](/assets/hash4.png)
Crackstation has not seen this has before.

#### Hash-Identifier

![Hash4 with hash-identifier](/assets/hash4-HI.png)  
Also unidentifiable by hash-identifier.

#### Hashcat

Here is the first one which is unidentified by both Crackstation and Hash-Identifier. We can resort to visual matching on the Hashcat exmaples page. The "$" is a separator. Performing a search for "$2y" yields no results. But if we understand this is still an entry level room, then the hash mode should still have a fairly small number, searching for "$2*" indicates bcrypt.
Bcrypt begins to get tougher. For this iteration, I chose to perform the operation on my Windows host, rather than the Kali VM. This lets me allow greater gpu and cpu allocation. Nothing realy changes. I simply put the hash into a file called hashes.txt and still use rockyou.txt, both located in the hashcat folder on the C drive. The command changes only slightly:  
:>````.\hashcat.exe -m 3200 -a 0 -w 4 -D 1,2 hashes.txt rockyou.txt````  
The result:  
![Hash4 with Hashcat](/assets/hash4-HC.png)

### Hash 5: 279412f945939ba78ce0758d3fd83daa

#### Crackstation

![Hash5](/assets/hash5.png)

#### Hash-Identifier

![Hash5 with hash-identifier](/assets/hash5-HI.png)

#### Hashcat

Attempt the MD4 as recommended.  
````hashcat -m 900 -a 0 hash5 /usr/share/wordlist/rockyou.txt````  
In this instance, and for some unexplained reason, hashcat is unable to crack this one, at least not with this list.  
![Hash5 MD4 Unsolved](/assets/hash5-HC-MD4.png)

Trying another of the recommendations, Radmin v2:  
````hashcat -m 9900 -a 0 hash5 /usr/share/wordlist/rockyou.txt````
![Hash5 Radmin Unsolved](/assets/hash5-HC-Radmin.png)

## Task 2

### Hash 6: F09EDCB1FCEFC6DFB23DC3505A882655FF77375ED8AA2D1C13F640FCCC2D0C85

#### Crackstation

![Hash6](/assets/hash6.png)

#### Hash-Identifier
![Hash6 with hash-identifier](/assets/hash6-HI.png)

#### Hashcat

With this hash, both Crackstation and Hash-Identifier identify this as SHA-256. Reviewing the example hashes in the Hashcat Wiki, there are a number of potential options beginning at mode 1400.
  
````hashcat -m 1400 -a 0 hash6 /usr/share/wordlist/rockyou.txt````  
![Hash6 with hashcat](/assets/hash6-HC.png)

### Hash 7: 1DFECA0C002AE40B8619ECF94819CC1B

#### Crackstation

![Hash7](/assets/hash7.png)

#### Hash-Identifier
![Hash7 with hash-identifier](/assets/hash7-HI.png)

#### Hashcat

Here is an instance where Crackstation and Hash-Identifer provide two different potential hash modes.
````hashcat -m 1000 -a 0 hash7 /usr/share/wordlist/rockyou.txt````  
Hashcat is able to crack the hash using the NTLM mode
![Hash 7 with hashcat](/assets/hash7-HC.png)

### Hash 8: $6$aReallyHardSalt$6WKUTqzq.UQQmrm0p/T7MPpMbGNnzXPMAXi4bJMl9be.cfi3/qxIf.hsGpS41BqMhSrHVXgMpdjS6xeKZAs02.
#### Salt: aReallyHardSalt

#### Crackstation
![Hash8](/assets/hash8.png)

#### Hash-Identifier
As the documentation indicates, hash-identifier works only with unsalted hashes.

#### Hashcat

With no previous identification, it's time to rely on key indicators:  
"$6$" and where it falls in the hash supports visual identification usingg the hashcat example hashes wiki.
The character space includes both forward slash ("/") and full-stop ("."). The presence of these two characters can further indicate potential hash modes if they are present in the example hashes.

sha512crypt has "$6$ in the correct location and a forward slash at the end. It is missing the full-stop.
````hashcat -m 1800 -a 0 hash8 /usr/share/wordlist/rockyou.txt````  
Hashcat accurately extracts the salt from the hash:  
![Hash 8 with hashcat mode 1800](/assets/hash8-HC01.png)  
and is able to decipher the hash.  
![Hash 8 with hashcat mode 1800](/assets/hash8-HC02.png)

### Hash 9: e5d8870e5bdd26602cab8dbe07a942c8669e56d6
#### Salt: tryhackme

#### Crackstation
![Hash9](/assets/hash9.png)

#### Hash-Identifier
As the documentation indicates, hash-identifier works only with unsalted hashes.

#### Hashcat

This hash has a much more limited characterspace than the previous exercise.  
With the file set up correctly, find out just how many characters are in the hash:  
````cut -d ":" -f1 hash9 | wc -c````  
Indicates there are forty-one characters in the hash.  
The most likely candidates for forty-one character hases are modes are 110-160.  
````hashcat -m 160 -a 0 hash9 /usr/share/wordlist/rockyou.txt````
![Hash9-Hashcat](/assets/hash9-HC.png)


## Identifying Hashes

Working in a profession means relying on tools avaialble to speed and automate work. It does not mean ignoring the value in learning about the tools. The [Hash-Identifer code](https://github.com/blackploit/hash-identifier/blob/master/hash-id.py) within Kali Linux provides an outstanding example for understanding the use of automation to identify hashes. Consider some example code from the tool:

### Tracking identified hashes

Hashes that have been identified need a c onssitent method by which the program indexes them. In this case, each hash type is associated with a string of numbers (significantly shortened, here).

````python
algorithms={"102020":"ADLER-32", "102040":"CRC-32", "SHA-512(HMAC)", "122040":"Whirlpool", "122080":"Whirlpool(HMAC)"}
````

### Evaluating Hashes

The evaluation functions receives the submitted hash and compares it against a series of reasonably standardized criteria to determine the likelihood of a match.

- The developer has provided the evaluation function with an example hash of the appropriate type against which the length of the submitted hash maybe compared  
- The .isdigit() method returns true if all characters in the string are digits. In the examples below, all contain letters, numbers, and special characters. The evaluation function wants the method to return "False".
- Similarly, the .isalpha() method returns true when all the characters in the string are letters. This will always return true for these functions, and every other secure hash.
- The .isalnum() method identifes a string comprised of both letters and numbers. In the below examples, the inclusion of a colon (:) in the SAM hash means the SAM function must return "False".
- Also specific within the SAM function is the use of the .find() method to verify the placement of the colon (:) at a specific position within the hash string
If all methods return as expected (via the use of if-and statement), the string assoicated with the hash type in the "algorithms" dictionary is appended toa list called "jerar".

````python
def MD4(hash):
    hs='a2acde400e61410e79dacbdfc3413151'
    if len(hash)==len(hs) and hash.isdigit()==False and hash.isalpha()==False and hash.isalnum()==True:
        jerar.append("106040")
def MD5(hash):
    hs='ae11fd697ec92c7c98de3fac23aba525'
    if len(hash)==len(hs) and hash.isdigit()==False and hash.isalpha()==False and hash.isalnum()==True:
        jerar.append("106020")
def SHA1(hash):
    hs='4a1d4dbc1e193ec3ab2e9213876ceb8f4db72333'
    if len(hash)==len(hs) and hash.isdigit()==False and hash.isalpha()==False and hash.isalnum()==True:
        jerar.append("109020")
def SAM(hash):
    hs='4318B176C3D8E3DEAAD3B435B51404EE:B7C899154197E8A2A33121D76A240AB5'
    if len(hash)==len(hs) and hash.isdigit()==False and hash.isalpha()==False and hash.isalnum()==False and hash.islower()==False and hash[32:33].find(':')==0:
        jerar.append("116040")
````

### Starting the application

The first try/except statement identifes whether or not a hash has been provided at by the user. If input is provided (presumably a hash) it will be converted to a string and assigned to the variable "first". If no input has been provided, first is set to none and this controls the flow of the application.  

````python
print(logo)
try:
    first = str(argv[1])
except:
    first = None
````

### Starting the Evaluation

The main body of the application initiates a while loop. IF there is a deficiency, is that there is no point in the application where the loop is ended by setting teh value of the while to False. That's a matter of prefernce and cleanliness. Not necessarily functionality.

The while loop is entered and the "jerar" list is created to hold the strings appended as a result of the evaluation functions included. The developer has provided a visual separation by printing a line of fifty hyphens.

The value assigned to the "first" variable is not tested to identify the next steps in the process. If "first" has a value, that value is assigned to "h". If "first" has no value, the application requests input from the user by dispalying " HASH: ".

Once "h" has a value, that value is passed to all the defined evaluation functions for consideration and, again, evaluation functions that return all the required values have identification strings appended to the "jerar" list created in this first try-except loop.

````python
while True:
    try:
        jerar=[]
        print("-"*50)
        if first:
            h = first
        else:
            h = input(" HASH: ")

        ADLER32(h); CRC16(h); CRC16CCITT(h); CRC32(h); CRC32B(h); DESUnix(h); DomainCachedCredentials(h); FCS16(h); GHash323(h); GHash325(h); GOSTR341194(h); Haval128(h); Haval128HMAC(h); Haval160(h); Haval160HMAC(h); Haval192(h); Haval192HMAC(h); Haval224(h); Haval224HMAC(h); Haval256(h); Haval256HMAC(h); LineageIIC4(h); MD2(h); MD2HMAC(h); MD4(h); MD4HMAC(h); MD5(h); MD5APR(h); MD5HMAC(h); MD5HMACWordpress(h); MD5phpBB3(h); MD5Unix(h); MD5Wordpress(h); MD5Half(h); MD5Middle(h); MD5passsaltjoomla1(h); MD5passsaltjoomla2(h); MySQL(h); MySQL5(h); MySQL160bit(h); NTLM(h); RAdminv2x(h); RipeMD128(h); RipeMD128HMAC(h); RipeMD160(h); RipeMD160HMAC(h); RipeMD256(h); RipeMD256HMAC(h); RipeMD320(h); RipeMD320HMAC(h); SAM(h); SHA1(h); SHA1Django(h); SHA1HMAC(h); SHA1MaNGOS(h); SHA1MaNGOS2(h); SHA224(h); SHA224HMAC(h); SHA256(h); SHA256s(h); SHA256Django(h); SHA256HMAC(h); SHA256md5pass(h); SHA256sha1pass(h); SHA384(h); SHA384Django(h); SHA384HMAC(h); SHA512(h); SHA512HMAC(h); SNEFRU128(h); SNEFRU128HMAC(h); SNEFRU256(h); SNEFRU256HMAC(h); Tiger128(h); Tiger128HMAC(h); Tiger160(h); Tiger160HMAC(h); Tiger192(h); Tiger192HMAC(h); Whirlpool(h); WhirlpoolHMAC(h); XOR32(h); md5passsalt(h); md5saltmd5pass(h); md5saltpass(h); md5saltpasssalt(h); md5saltpassusername(h); md5saltmd5pass(h); md5saltmd5passsalt(h); md5saltmd5passsalt(h); md5saltmd5saltpass(h); md5saltmd5md5passsalt(h); md5username0pass(h); md5usernameLFpass(h); md5usernamemd5passsalt(h); md5md5pass(h); md5md5passsalt(h); md5md5passmd5salt(h); md5md5saltpass(h); md5md5saltmd5pass(h); md5md5usernamepasssalt(h); md5md5md5pass(h); md5md5md5md5pass(h); md5md5md5md5md5pass(h); md5sha1pass(h); md5sha1md5pass(h); md5sha1md5sha1pass(h); md5strtouppermd5pass(h); sha1passsalt(h); sha1saltpass(h); sha1saltmd5pass(h); sha1saltmd5passsalt(h); sha1saltsha1pass(h); sha1saltsha1saltsha1pass(h); sha1usernamepass(h); sha1usernamepasssalt(h); sha1md5pass(h); sha1md5passsalt(h); sha1md5sha1pass(h); sha1sha1pass(h); sha1sha1passsalt(h); sha1sha1passsubstrpass03(h); sha1sha1saltpass(h); sha1sha1sha1pass(h); sha1strtolowerusernamepass(h)
````

### Producing Results

If the length of the jerar array is zero, the application has failed to identify any hash. Simple enough.
If there are one or two identification strings in 'jerar' the "else" statement sorts the identification strings, and prints the name of each hash in the "algorithm" dictionary assoicated with the identification string at position 'a' in the 'jerar' list. Since this is the "else" statement, the length of 'jerar' can be only 1 or 2.

The 'elif' statement provides the most robust feedback. Understanding the sorting and output requires understanding of how operating systems sort strings. In the case of hash-identifer, lower "value" strings are assigned to the most commonly used versions of hash types. For example, if hash-identifer appends the string values associated with RipeMD-128 (106180) and RipeMD-128(HMAC) (106185), the sort method will result in the string associated with RipeMD-128 being sorted to the front of the 'jerar' list. Since RipeMD-128 is, presumably, more frequently employed "in the wild" it is more likely a submitted hash will be RipeMD-128 than RipeMD-128(HMAC).

The least-likely hashes begins printing the hash names at position jerar[2] and beyond. It's not that these are not possible, they simply aren't as likely as the hash types at positions jerar[0] and jerar[1].

````python
        if len(jerar)==0:

            print("\n Not Found.")
        elif len(jerar)>2:
            jerar.sort()
            print("\nPossible Hashs:")
            print("[+] "+str(algorithms[jerar[0]]))
            print("[+] "+str(algorithms[jerar[1]]))
            print("\nLeast Possible Hashs:")
            for a in range(int(len(jerar))-2):
                print("[+] "+str(algorithms[jerar[a+2]]))
        else:
            jerar.sort()
            print("\nPossible Hashs:")
            for a in range(len(jerar)):
                print("[+] "+str(algorithms[jerar[a]]))

        first = None
````

### El Fin

The only way to end the application is keyboard interrupt. Simple and complete.  

````python
    except KeyboardInterrupt:
        print("\n\n\tBye!")
        exit()
````

more to follow...