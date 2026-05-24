# Critical

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

## Incident Scenario

Our user "Hattori" has reported strange behavior on his computer and realized that some PDF files have been encrypted, including a critical document to the company named important_document.pdf. He decided to report it; since it was suspected that some credentials might have been stolen, the DFIR team has been involved and has captured some evidence. Join the team to investigate and learn how to get information from a memory dump in a practical scenario.

Subject: memory forensics

tool: volatility

## Help Menu

```text
:> vol -h
```

Get info on windows OS

```text
:> vol -f <memdump.mem> windows.info
```

Get windows network information

```text
:> vol -f <memdump.mem> windows.netstat
```

Get windows process tree

```text
:> vol -f <memdump.mem windows.pstree
```

Get windows network connections

```text
:> vol -f <memdump.mem windows.netscan
```

Windows directories and files

```text
:> vol -f <memdump.mem> windows.filescan
```

Detailed data on file usage

```text
:> vol -f <memdump.mem> windows.mftscan.MFTScan
```

Detailed information on a particular process

```text
:> vol -f <memdump.mem> windows.memmap.Memmap -o <output file> --dump --pid <pid>
:> strings <output file>.dmp
```
