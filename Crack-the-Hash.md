# Crack The Hash

https://tryhackme.com/room/crackthehash

This is the ultimate in beginner rooms. Hash cracking is a great way to start because there are plenty of online resources to help. Cracking hashes is deterministic. There is really only one correct answer and it helps to have some immediate success when you are new to the craft.

In this room, each hash only needs one solution. Maybe we can create some success for people by exploring the multiple tools available to perform the cracking.

This is the list of tools we will highlight for each hash.. when possible.

**CrackStation**
https://crackstation.net/
Crackstation is, fundamentally, a library of pre-cracked, unsalted hashes. A great go-to tool for the first step in any attempt to crack a hash.

**hash-identifier**
https://gitlab.com/kalilinux/packages/hash-identifier/-/blob/kali/master/hash-id.py<br>

Let's interpret the main() of the hash-identifier source code<br>

````python
# simply print the value of the logo variable, set in the lower numbered lines of the source code
print(logo)

# set the value of 'first' by attempting to convert the value of argv[1] to a string
# If you have not experienced command line functions, they are simply an array where argv[0] is the title or name of the command and argv[1..n] represents options and flags required when the command is called.
# If the user has supplied a hash at argv[1], then 'first' will assume that value as a string.
# If the user has supplied no hash, or if the input at argv[1] cannot be converted to a string, then first is set to 'None'
try:
    first = str(argv[1])
except:
    first = None

while True:
    try:
        jerar=[]
        print("-"*50)
        if first:
            h = first
        else:
            h = input(" HASH: ")

        ADLER32(h); CRC16(h); CRC16CCITT(h); CRC32(h); CRC32B(h); DESUnix(h); DomainCachedCredentials(h); FCS16(h); GHash323(h); GHash325(h); GOSTR341194(h); Haval128(h); Haval128HMAC(h); Haval160(h); Haval160HMAC(h); Haval192(h); Haval192HMAC(h); Haval224(h); Haval224HMAC(h); Haval256(h); Haval256HMAC(h); LineageIIC4(h); MD2(h); MD2HMAC(h); MD4(h); MD4HMAC(h); MD5(h); MD5APR(h); MD5HMAC(h); MD5HMACWordpress(h); MD5phpBB3(h); MD5Unix(h); MD5Wordpress(h); MD5Half(h); MD5Middle(h); MD5passsaltjoomla1(h); MD5passsaltjoomla2(h); MySQL(h); MySQL5(h); MySQL160bit(h); NTLM(h); RAdminv2x(h); RipeMD128(h); RipeMD128HMAC(h); RipeMD160(h); RipeMD160HMAC(h); RipeMD256(h); RipeMD256HMAC(h); RipeMD320(h); RipeMD320HMAC(h); SAM(h); SHA1(h); SHA1Django(h); SHA1HMAC(h); SHA1MaNGOS(h); SHA1MaNGOS2(h); SHA224(h); SHA224HMAC(h); SHA256(h); SHA256s(h); SHA256Django(h); SHA256HMAC(h); SHA256md5pass(h); SHA256sha1pass(h); SHA384(h); SHA384Django(h); SHA384HMAC(h); SHA512(h); SHA512HMAC(h); SNEFRU128(h); SNEFRU128HMAC(h); SNEFRU256(h); SNEFRU256HMAC(h); Tiger128(h); Tiger128HMAC(h); Tiger160(h); Tiger160HMAC(h); Tiger192(h); Tiger192HMAC(h); Whirlpool(h); WhirlpoolHMAC(h); XOR32(h); md5passsalt(h); md5saltmd5pass(h); md5saltpass(h); md5saltpasssalt(h); md5saltpassusername(h); md5saltmd5pass(h); md5saltmd5passsalt(h); md5saltmd5passsalt(h); md5saltmd5saltpass(h); md5saltmd5md5passsalt(h); md5username0pass(h); md5usernameLFpass(h); md5usernamemd5passsalt(h); md5md5pass(h); md5md5passsalt(h); md5md5passmd5salt(h); md5md5saltpass(h); md5md5saltmd5pass(h); md5md5usernamepasssalt(h); md5md5md5pass(h); md5md5md5md5pass(h); md5md5md5md5md5pass(h); md5sha1pass(h); md5sha1md5pass(h); md5sha1md5sha1pass(h); md5strtouppermd5pass(h); sha1passsalt(h); sha1saltpass(h); sha1saltmd5pass(h); sha1saltmd5passsalt(h); sha1saltsha1pass(h); sha1saltsha1saltsha1pass(h); sha1usernamepass(h); sha1usernamepasssalt(h); sha1md5pass(h); sha1md5passsalt(h); sha1md5sha1pass(h); sha1sha1pass(h); sha1sha1passsalt(h); sha1sha1passsubstrpass03(h); sha1sha1saltpass(h); sha1sha1sha1pass(h); sha1strtolowerusernamepass(h)

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
    except KeyboardInterrupt:
        print("\n\n\tBye!")
        exit()

````

**Hashcat**
https://hashcat.net/wiki/
An advanced password recovery tool (password cracking). The user cannot be afraid to continually reference the wiki and learn about the intricacies of Hashcat. It's capabilities are limited only by the user's curiosity. The

**John The Ripper**
Would be appropraitely names Jack of All Trades. John has the ability to perform password security auditing and recovery across operating systems as well as file types, including unix, macOS, Windows, web apps, groupware, zip files, and others. 

### Setup Notes ###
Because of the potential level of repetition, each hash was placed in its own file in the Kali Linux environment. This facilitates some efficiencies when using the command line.<br>
![Screenshot of hash files inside the Kali Linux fs](/Screenshots/kaliHashfiles.png)<br>



## Task 1 ##
### Hash 1: 48bb6e862e54f2a795ffc4e541caed4d ###
#### Crackstation ####
![Hash1](/Screenshots/hash1.png)<br>
#### Hash Identifier ####
The simplest use of hash identifier is as any other linux command.<br>
:> hash-identifier 48bb6e862e54f2a795ffc4e541caed4d <br>
![Hash1 with hash-identifier](/Screenshots/hash1-HI.png)<br>


### Hash 2: CBFDAC6008F9CAB4083784CBD1874F76618D2A97 
#### Crackstation ####
![Hash2](/Screenshots/hash2.png)<br>

### Hash 3: 1C8BFE8F801D79745C4631D09FFF36C82AA37FC4CCE4FC946683D7B336B63032 ###
#### Crackstation ####
![Hash3](/Screenshots/hash3.png)<br>

### Hash 4: $2y$12$Dwt1BZj6pcyc3Dy1FWZ5ieeUznr71EeNkJkUlypTsgbX1H68wsRom ###
#### Crackstation ####
![Hash4](/Screenshots/hash4.png)<br>
Crackstation has not seen this has before.

### Hash 5: 279412f945939ba78ce0758d3fd83daa ###
#### Crackstation ####
![Hash5](/Screenshots/hash5.png)<br>


## Task 2 ##

### Hash 6: F09EDCB1FCEFC6DFB23DC3505A882655FF77375ED8AA2D1C13F640FCCC2D0C85 ###
#### Crackstation ####
![Hash6](/Screenshots/hash6.png)<br>

### Hash 7: 1DFECA0C002AE40B8619ECF94819CC1B ###
#### Crackstation ####
![Hash7](/Screenshots/hash7.png)<br>

### Hash 8: $6$aReallyHardSalt$6WKUTqzq.UQQmrm0p/T7MPpMbGNnzXPMAXi4bJMl9be.cfi3/qxIf.hsGpS41BqMhSrHVXgMpdjS6xeKZAs02. ###
### Salt: aReallyHardSalt ###
#### Crackstation ####
![Hash8](/Screenshots/hash8.png)<br>

### Hash 9: e5d8870e5bdd26602cab8dbe07a942c8669e56d6 ###
### Salt: tryhackme ###
#### Crackstation ####
![Hash9](/Screenshots/hash9.png)<br>