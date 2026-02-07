# iOS Forensics

## What is Digital Forensics and how is it Used Today?

digitisation of the traditional use and applications of forensic investigation after a crime has been committed.  
 
collection of artefacts on a digital device.  
 
Removing evidence or covering your tracks is a fallacy to some extent - especially with digital devices. 
Someone may be able to hide exactly what they were doing, however, the act of hiding this will, in turn, leave the trace of something behind hidden. 

we will find nothing meaningful on a hard drive full of zeros  
it's what isn't there anymore that is indicative. Obviously, some efforts have been made to hide data  
 
For example. You may consider the privacy of your browsing and social media, but then you have a smart meter in the house! As (S. Kim et al, 2020) were able to create a day-to-day schedule of a participant's actions simply by using the timestamps of when doors open and close - all from the data stored within a Samsung SmartThings.  
 
Real-World Uses:  
 
Digital forensics isn't only used in investigations by the authorities but has an extremely heavy and necessary footprint in every sector of the world. All too often we often hear about companies being hacked (fourth wall break?). Companies need to understand the chain of events on how they were breached and what data was taken, this is known as incidence response.  
 
Not only this but, digital forensics serves a large role in civil and workplace matters. A few examples that come to mind is determining whether or not an employee is selling trade secrets to a competitor. Who is selling them, what secrets are being sold? And more importantly - who to?  
 
One of the only times that digital forensics is in your favour is the recovery of lost data, but the details of that are for a future room or two.  

## Problems Facing Digital Forensic Analysts

### Time Consumption & Resources

incredibly time-consuming process  
having to analyse data bit-by-bit to find that one smoking gun  
extend that to a 1TB drive - not so fun huh.  
exact bit-for-bit copies of an acquired device or system  
the facilities to be able to store this data before it can be processed  
-10 terabytes of data  
-10 terabytes to store that on as well  
-10 terabytes required for the backups of the image that you make  
-at least 20 terabytes sitting around.  

### Understanding the Person

piece various parts of information together into a formal and well-documented timeline of events for presentation  

### Encryption

effective and secure implementation of encryption poses as one of the biggest hurdles  
People and/or devices themselves leave the decryption keys within the same platform  
a complex password is a strong password until you need to write it down.  

### Steganography

Hiding data within data  
in some cases more secure then cryptography  
cryptography makes the contents unreadable, steganography masquerades the entire existence of this data altogether  

### Cost of Entry

pick up FTK Imager lite or Autopsy for free, but these tool suites are only the tip of the iceberg in digital forensics.  

not going to be creating any file system images of iPhones in FTK Imager lite, and if so, you're going through it bit-for-bit if it is at all unencrypted.  

Enter infamous companies such as Cellebrite. This company are arguably the forefront of data acquisition. Costing approximately $15,000 for the equipment and adapters, specialist kits such these aren't available to hobbyists - only to law enforcement, government agencies and specific Universities. Cellebrite was used to dump this iPhone.  

Let alone the cost of purchasing sophisticated tools, there is a heavy expectation of certifications and even degrees; that's what filled most of my 3 years at University  

## iOS File Systems

Apple created their own sets of file system formattings: AFS and HFS+  
 
 HFS+ or Mac OS Extended, oldest,  
-the legacy file system used by Apple all the way in 1998 and is still supported today  
-HFS was not future proof - given the fact it cannot support file timestamps past February 6th, 2040 (Vigo., 2018).  
-didn't support encryption at its entirety (a win in our books as forensic analysts)  
 
 any device such as iMac or iPhone past iOS 10.3 will have had their file system converted from HFS+ to AFS automatically.  
 
AFS or Apple File System (creative right...!)  
-full disk encryption  
-introduces smarter data management  
-Instead of writing and storing the entire copies of data AFS creates another reference to the same data; similar to inodes in Linux.  

![AFS](/assets/forensics-101.png)  

## Modern iOS Security

UFED toolkit can use all of the acquisition methods discussed in "Analyzing iOS Files"  
UFED is capable of forcing the iDevice to boot using UFED's custom boot loader, bypassing the entire iOS operating system - similar to rooting an android; resulting in an entire dump of the entire device.  
contradicts the golden rule of digital forensics: Never turn it off.  
 
People often install "panic switches" into devices, where a shutdown event could trigger an entire wiping of the device. Or in the case of iPhones, if the iPhone isn't properly isolated, it can be remotely wiped via the iCloud  
 
### iOS "Restricted Mode"
 
Since 2018  
on all iDevices running that version and above  
disables the input/output of data functionality from the lightning (charge) cable until the iPhone is unlocked with a passcode  
Devices must be trusted before any data can be written - or so as by design.  

## Data Acquistion and Trust Certificates

This room is going to situate ourselves as digital forensic experts for a police department, and as such, we'll discuss the techniques that - we - as experts would use and the issues surrounding them.  
 
In modern-day digital forensics, there are four primary methods and procedures followed when trying to retrieve data from devices such as iPhones. How an analyst approaches a device is arguably the most important decision they'll make. If the wrong call was made, data that could have been retrieved may end up deleted, or just as worse, inadmissible as evidence due to incorrect technique or failure to follow policy.  
 
In a court of law, any evidence submitted must be admissible. This complex process involves the "chain of custody". No matter how indicting a piece of evidence is, it can be dismissed if there is insufficient documentation and/or negligence in handling - all the way from the crime scene to the courtroom.  

Entire policing frameworks are built solely to ensure the integrity of digital evidence such as the "ACPO Good Practice Guide" for police forces in the UK. I really encourage a read through!  


### Direct Acquisition:
 
Non-forensically focused, and most importantly free, applications such as the iFunbox perform the same job in this scenario.  
 
Direct acquisition covers three scenarios:  
  
1. There is no password on the phone  
2. There is a password but it is known to the analyst  
3. The analyst has a "Lockdown Certificate" which is what we'll come onto in just a bit.  
 
applications such as the iFunbox are capable of writing to the device being analysed  
-the image made will now be inadmissible as evidence due to the fact that there's a possibility data was (over)written to the device that wasn't from the suspect - a defence attorney can argue the data could have been left by the forensic analyst.  
 
### Logical or Backup Acquisition
 
cheapest way of acquiring data from a device  
using iTunes' backup facility, analysts can simply use a computer that has been paired with the iPhone before  
Logical acquisition is where the big money starts to roll in. You're going to be hearing of Cellebrite a lot, they're quite the giant in a very specialist field because of their incredible kit, making the actual stage of accumulating data ten-fold.  
 
### iTunes Backups & Trust Certificates
 
iTunes accesses the iPhone in a privileged state - similar to using the sudo command on Linux to run a command with root privileges.  
will only backup to trusted computers  
When plugging into a new device, the iPhone will ask the user whether or not they wish to trust the computer  
"Trusting" a computer involves generating a pair certificate on both the iPhone and computer  
A lockdown certificate stored within /private/var/db/lockdown on later iOS devices or /private/var/Lockdown on older iOS devices  
in Windows, this certificate is stored in C:\ProgramData\Apple\Lockdown  
The certificate within the computer contains the private keys used to encrypt and decrypt against the iPhones public key:  
 

### Trust Certificates Explained
 
Trust certificates aren't permanent by design  
Trust certificates, at an abstract work in the following way:  
 
iTunes will generate a certificate using the iPhone's unique identifier once data read/write has been allowed by trusting the computer on the iPhone.  
This certificate will be stored on the trusted computer for 30 days. Afterwhich you will need to re-trust the device.  
However, the certificate that is generated can only be used for 48 hours since the user has last unlocked their iPhone. Let's break this down:  
 
If the iPhone has been connected to a trusted computer but the iPhone hasn't been unlocked in a week, the certificate won't be used although it is still valid. Once the iPhone is unlocked, the iPhone will automatically allow read/write access by the trusted computer without the "Trust This Computer" popup.  
However, if you were to connect the iPhone to the trusted computer 6 hours since it was last unlocked, the iPhone will allow read/write access straight away.  
 
### How can We Utilise These Trust Certificates?
 
First, we need to understand the backups that iTunes creates. iTunes allows for two types of backups resulting in different amounts of data being backed up onto the computer and ultimately how it should be analysed: "Unencrypted" and "Encrypted"  

Unencrypted backups are simply that - unencrypted. Perfect! We'll have a copy of photos that aren't synced to iCloud, a copy of browsing history and the likes. However, no passwords or health and Homekit data - these are only backed up if the "Encrypted" option is set by the user.  
 
Remembering that iTunes accesses the iPhone with elevated privileges using lockdown certificates, we can extract data from the iPhone such as the keychain. This keychain includes (but isn't limited) to passwords such as:  
 
    Wi-Fi Passwords  
    Internet Account Credentials from " Autofill Password"  
    VPN  
    Root certificates for applications  
    Exchange / Mail credentials  

## Looking for Loot

mobile devices are quite literal extensions of our lives, and as such, hold everything someone could ever want to know about us.

Paying through contactless payments, sending memes via Discord or checking in back home and letting Mum know you're okay; it's all recorded. Where? On your phone!

log files of connections to WiFi cellular towers are the least of concerns in privacy on your phone when you can see the data that can be extracted from such small devices.

## Analyzing iOS Files

### PLISTs

extension which indicates files containing properties  
consists of data from anything: preferences, applciation settings, data  
XML formatted  
some will open with text editor others open only with hex editor

### Databases

sqlite or db format  
used for structured data (SMS, Contacts, Email, eg..)  

