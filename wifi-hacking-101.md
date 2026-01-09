# Wi-Fi Hacking 101

## Technologies

- WPA2  
- aircrack-ng  

## The Basics  

### Key Terms

    - SSID: The network "name" that you see when you try and connect  
    - ESSID: An SSID that *may* apply to multiple access points, eg a company office, normally forming a bigger network. For Aircrack they normally refer to the network you're attacking.  
    - BSSID: An access point MAC (hardware) address  
    - WPA2-PSK: Wifi networks that you connect to by providing a pre-shared password that's the same for everyone  
    - WPA2-EAP: Wifi networks that you authenticate to by providing a username and password, which is sent to a RADIUS server.  
    - RADIUS: A server for authenticating clients, not just for wifi.  

    
    - MSK - Master Session Key is used to derive unique PMK for each different client in an enterprise network  
    - PMK - Pairwise Master Key is a 256-bit key at the top of the key hierarchy and is used indirectly for unicast traffic and the WPA 4-way handshake. The wireless client and AP have the PMK, which should last the entire session, so it should not be exposed. not used to encrypt the traffic directly  
    - GMK - Group Master Key is a 128-bit key at the top of the hierarchy for broadcast and multicast traffic. The AP generates a cryptographic-quality random number. The GMK is not exchanged directly but is used to derive a group temporal key (GTK). The GMK can be regenerated periodically to reduce the risk of being compromised.
    - PTK - Pairwise Transient Key derived from the GMK (which is derived using random number) using a PRF and protects all broadcast and multicast traffic between the AP and wireless clients associated with the AP. All wireless clients use the same GTK. During the WPA 4-way handshake, the GTK is sent from the AP to the wireless client. When the AP renews the GTK, it uses a group key handshake called a 2-way handshake. The 2-way handshake is encrypted and does not show up in Wireshark as EAPOL packets. You need to decrypt the packet using passowrd:ssid of the network.  
    - GTK - Group Temporal Key is divided into encyption key and MIC key  
    - MIC - Message Integrity Code  


### The 4-Way Handshake  

Source: [The Kernel Blog](https://kernelblog.com/posts/4-way-handshake-in-802.11-wi-fi/)  

 

#### The state of a machine joining and Access Point (AP)  


  1. Unauthenticated and Unassociated  
  2. Authenticated and Unassociated  
  3. Authenticated and Associated  
  4. Exchange Keys using 4WHS  

#### The Process

![messages](/assets/wifi-hacking-100.png)  
![process](/assets/wifi-hacking-101.png)  

## Aircrack-ng 

`:> aircrack-ng -b 02:1A:11:FF:D9:BD -j crackme -w /usr/share/wordlists/rockyou.txt NinjaJc01-01.cap`  

![aircrack-ed](/assets/wifi-hacking-102.png)  