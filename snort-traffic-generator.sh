#!/bin/bash
selection=$(zenity --list \
"1) ICMP Traffic" \
"2) HTTP Traffic" \
"3) TASK-6 Exercise" \
"4) TASK-7 Exercise" \
"5) TASK-10 IPS Exercise - Port 4444 Traffic" \
"6) TASK-10 IPS Exercise - Torrent Traffic" \
 --column="" --text="Select a traffic pattern to feed the pig!" --title="Traffic Generator" --width=450 --height=450)
case "$selection" in
"1) ICMP Traffic")gnome-terminal --hide-menubar --title="ICMP Traffic" --geometry=120x32 -e 'tcpreplay -v --mbps=0.005 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/icmp-test.pcap';;
"2) HTTP Traffic")gnome-terminal --hide-menubar --title="HTTP Traffic" --geometry=120x32 -e 'tcpreplay -v --mbps=0.03 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/mx-1.pcap';;
"3) TASK-6 Exercise")gnome-terminal --hide-menubar --title="TASK-6 Exercise" --geometry=120x32 -e 'tcpreplay -v --mbps=0.03 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/mx-1.pcap';;
"4) TASK-7 Exercise")gnome-terminal --hide-menubar --title="TASK-7 Exercise" --geometry=120x32 -e 'tcpreplay -v --mbps=0.03 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/mx-1.pcap';;
"5) TASK-10 IPS Exercise - Port 4444 Traffic")gnome-terminal --hide-menubar --title="TASK-10 IPS - ICMP Traffic" --geometry=120x32 -e 'tcpreplay -v --mbps=0.007 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/44m.pcap';;
"6) TASK-10 IPS Exercise - Torrent Traffic")gnome-terminal --hide-menubar --title="TASK-10 IPS - Torrent Traffic" --geometry=120x32 -e 'tcpreplay -v --mbps=0.009 -i eth0 /home/ubuntu/Desktop/Task-Exercises/.traffic-generator-source/torrent.pcap';;
esac