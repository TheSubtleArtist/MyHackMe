# YARA

## References

[YARA in a Nutshell by VirusTotal](https://virustotal.github.io/yara/)  
[Yara Documentation](https://yara.readthedocs.io/en/stable/index.html)  
[YARA-CI](https://yara-ci.cloud.virustotal.com/)  
[InQuest Yara Rules](https://github.com/InQuest/awesome-yara)  

## Summary

Proprietary language use for the identification and classification of malware samples.  
Used to create descriptions of malware families based on text or binary samples.  
Rules lable the patterns which identify malware as malicious, or not.  

### Yara Rules

Valid Yara rules require two arguments.  

- The rule file ("myrule.yar")  where `.yar` is the standard extension
- Name of file, directory, or process ID to use the rule for.  ("somedirectory)"  

Implementing the rules: `:> yara myrule.yar somedirectory`  

### Strings

Keyword "strings" contains the string(s) used to identify the malware  
Search for specific text or hexadecimal in files or programs  

```md
rule helloworld_checker{
	strings:
		$hello_world = "Hello World!"
}
```

### Conditions  

Used to validate the rule.  

```md
rule helloworld_checker{
	strings:
		$hello_world = "Hello World!"
    condition:
        $hello_world
}
```

If the file containst the string "Hello World" the rule will match. Will not match variations.  

#### Increase the Chance for Match  

```md
rule helloworld_checker{
	strings:
		$hello_world = "Hello World!"
        $hello_world_lowercase = "hello world"
        $hello_world_uppercase = "HELLO WORLD"
    condition:
        any of them
}
```

Will match any of the strings contained in any of the three variables.  

#### Operators  

<= (less than or equal to)  
>= (more than or equal to)  
!= (not equal to)  

```md
rule helloworld_checker{
	strings:
		$hello_world = "Hello World!"
	condition:
        #hello_world <= 10
}
```  

The rule will now:

1. Look for the "Hello World!" string
2. Rule matches if there are ten or fewer occurrences of the "Hello World!" string

#### Combining Conditions  

- and
- not
- or

```md
rule helloworld_checker{
	strings:
		$hello_world = "Hello World!" 
        condition:
	        $hello_world and filesize < 10KB 
}
``` 
Check if a file has a string and is of a certain size.  
Rule matches if both conditions are true.  


[All Conditions](https://yara.readthedocs.io/en/stable/writingrules.html#conditions)  

#### Meta

Used for descriptive information about the rules

### Rule Anatomy

```md

// Modules extend functionality
import pe

// Rule name identifies the rule and should add meaning
// global ruiles apply to all rules in the file
// private rules can be called in a condition of a rulie, but cannot be reported
// rule tags filter yara's output
rule PlayForESXi : Tag1 Demo
{
    meta:
        // Provide context for analysis
        description = "Detects PLAY ransomware targeting ESXi Hypervisors"
        author = "Threat Research Team"
        date = "2025-01-15"
        filetype = "elf"
        maltype = "ransomware"
        reference = "https://example.com/play-ransomware-analysis"

    strings:
        // define the text, hex, and / or regex strings required for matching
        $encrypt_str = "encrypt:" 
        $first_step_done = "First step is done."
        $vmfs_path = "/vmfs/volumes" 
        $play_extension = ".PLAY" fullword
        $stop_list_mode = "stop list mode"
        $exclusion_hosts = "hosts in exclusion:"
        $error_stop_list = "Error, check stop list file, exit."
        $complete_msg = "Complete."
        $urandom_path = "/dev/urandom"

        // Targeted VM file extensions ('fullword' modifier avoids false positives)
        $vmdk_ext = ".vmdk" fullword
        $vmem_ext = ".vmem" fullword
        $vmsd_ext = ".vmsd" fullword
        $vmsn_ext = ".vmsn" fullword
        $vmx_ext = ".vmx" fullword
        $vmxf_ext = ".vmxf" fullword
        $vswp_ext = ".vswp" fullword
        $vmss_ext = ".vmss" fullword
        $nvram_ext = ".nvram" fullword
        $vmtx_ext = ".vmtx" fullword
        $log_ext = ".log" fullword

        // Command-line indicators
        $power_off_cmd = "vim-cmd vmsvc/power.off"
        $get_storage_cmd = "esxcli storage filesystem list > storage"
        $get_vms_cmd = "vim-cmd vmsvc/getallvms > machines"

    condition:
        // boolean expressions used to match the defined pattern
        $encrypt_str and 
        $first_step_done and 
        $vmfs_path and
        
        // At least one VM extension targeted
        (
            $vmdk_ext or $vmem_ext or $vmsd_ext or $vmsn_ext or 
            $vmx_ext or $vmxf_ext or $vswp_ext or $vmss_ext or 
            $nvram_ext or $vmtx_ext
        ) and
        
        // Presence of command execution patterns
        $power_off_cmd and 
        ($get_storage_cmd or $get_vms_cmd) and
        
        // Ransom note or logging artifacts
        ($complete_msg or $error_stop_list)
}

```

## Yara Modules

### PE

create more fine-grained rules for PE files  
add features and attributes of PE file format  
exposes fields present in a PE header
Provides function used to write targeted rules

```md
import "pe"

rule single_section
{
    condition:
        pe.number_of_sections == 1
}

rule control_panel_applet
{
    condition:
        pe.exports("CPlApplet")
}

rule is_dll
{
    condition:
        pe.characteristics & pe.DLL
}

rule is_pe
{
    condition:
        pe.is_pe
}
```

### ELF

similar to the PE module
exposes fields present in an ELF header  

```md
import "elf"

rule single_section
{
    condition:
        elf.number_of_sections == 1
}

rule elf_64
{
    condition:
        elf.machine == elf.EM_X86_64
}
```


### Cuckoo

create YARA rules based on behavioral information generated by Cuckoo sandbox  
pass additional information about file behavior to the cuckoo module  
create rules based what file contains as well as what it does  
not built into YARA by default  [Cmpile and install Cuckoo](https://yara.readthedocs.io/en/stable/gettingstarted.html#compiling-yara)

```md
rule evil_doer
{
    strings:
        $evil_domain = "http://someone.doingevil.com"

    condition:
        $evil_domain
}
```

### Magic

identify the type of the file based on the output of the Linux `file` command  
not built into YARA by default  [Cmpile and install Cuckoo](https://yara.readthedocs.io/en/stable/gettingstarted.html#compiling-yara)  

***`type()` function***  
returns the descriptive string  output by the Linux `file` command  

***`mime_type()` function***
similar to passing the --mime argument to the Linux `file` command  

### Hash

calculate hashes (MD5, SHA1, SHA256) from portions of the file and create signatures based on those hashes  
depends on the OpenSSL library

### Math

calculate certain values from portions of the file and create signatures based on those results  
YARA is able to convert integers to floating point numbers during most operations  

### Dotnet

create more fine-grained rules for .NET files  

```md
import "dotnet"

rule not_exactly_five_streams
{
    condition:
        dotnet.number_of_streams != 5
}

rule blop_stream
{
    condition:
        for any i in (0..dotnet.number_of_streams - 1):
            (dotnet.streams[i].name == "#Blop")
}
```

### Time

use temporal conditions in YARA rules

### Console

log information during condition execution  
By default, the log messages are sent to stdout but can be handled differently by using the C api  

```md
import "console"

rule example
{
    condition:
        console.log("Hello") and console.log("World!")
}
```

### String  

functions for manipulating strings as returned by modules

### LNK

create more fine-grained rules for LNK files  
Shell Link Binary File Format contains information that can be used to access another data object  
[Microsoft Link Documentation](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-shllink/16cb4ca1-9339-4d0c-a68d-bf1d6cc0f943)  

```md
import "lnk"

rule is_lnk
{
    condition:
        lnk.is_lnk
}

rule machine_id_tracking
{
    condition:
        lnk.tracker_data.machine_id == "chris-xps"
}

rule local_base_path
{
    condition:
        lnk.link_info.local_base_path == "C:\\test\\a.txt"
}
```

## Other Tools and Yara

### Thor Lite

[Free IOC and YARA Scanner](https://www.nextron-systems.com/thor-lite/)

includes the file system and process scan module as well as module that extracts “autoruns” information on the different platforms  
Open Source [signature base](https://github.com/Neo23x0/signature-base)  
encrypted open source signature set, update utility to download new versions with signature updates, documentation and option to add your custom IOCs and signatures

### Fenrir

simple IOC scanner bash script  
allows scanning Linux/Unix/OSX systems for [specific IOC](https://github.com/Neo23x0/Fenrir)

### YAYA

Threat Hunting Tool From [EFF](https://www.eff.org/deeplinks/2020/09/introducing-yaya-new-threat-hunting-tool-eff-threat-lab) Threat Lab  

open source tool to help researchers manage multiple YARA rule repositories
geared towards new and experienced malware researchers  

### Valhala

[online Yara feed](https://www.nextron-systems.com/valhalla/)
conduct searches based on a keyword, tag, ATT&CK technique, sha256, or rule name.