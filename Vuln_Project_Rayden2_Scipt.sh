#!/bin/bash
# Script to install all tools/software needed
# Automate Nmap scans and Nmap scripts
# Nmap scans to determine, ip address online, open ports and it's service version
# Nmap scripts to identify vulnerability
# Hydra to perform dictionary attack to identify weak passwords


# Font Variables
UNDERLINE='\e[4m'
BOLD='\e[1m'
RESET='\e[0m'
GREEN='\e[32m'
RED='\e[31m'

# create a interactive Header and Menu

echo -ne "$BOLD $GREEN
WELCOME TO RAYDEN's SCRIPT
VERSION 3.0 $RESET
"


####Get IP Range to scan, Prepare Directory, Prepare Wordlists
read -p "Which IP address range to scan (e.g 10.10.100.0/24): " IPADD
cd
mkdir VulnProject 2>/dev/null
cd ~/VulnProject
mkdir Wordlists 2>/dev/null
cd ~/VulnProject/Wordlists
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt 2>/dev/null
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/2020-200_most_used_passwords.txt 2>/dev/null
	
####Check/Install Tools 
#Nmap and update script-db

	NMAP=$( which nmap )
	if [ -z $NMAP ]

	then
	sudo apt-get update
	sudo apt install nmap
fi
	#Download Vulscan script and link it to /usr/share/nmap/scripts/vulscan
	cd ~/VulnProject
	git clone https://github.com/scipag/vulscan scipag_vulscan
	sudo ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan

#Hydra
HYDR=$( which hydra )
if [ -z "$HYDR" ]

then 
sudo apt update
sudo apt install hydra
fi

#Masscan
MASS=$( which masscan )
if [ -z "$MASS" ]

then 
sudo apt update
sudo apt install masscan
fi	


####Find Online IP(s), Nmap scan for all open TCP service, Masscan for all open UDP service, scripts to identify vulnerability, Hydra to identify weak user:pass
	
##Function to Find Online IP

function SCANIPRANGE ()
	{
	cd
	MYIP=$(hostname -I)
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	IPADDRANGE=Nmap_IP_Range_$TIMESTAMP.txt

	
	echo "Starting Online IP scan"
	
	nmap -sn --exclude $MYIP $IPADD >> ~/VulnProject/nmap_rawdata_$TIMESTAMP
	cat ~/VulnProject/nmap_rawdata_$TIMESTAMP | grep -i 'Nmap scan report for' | awk '{print $5}' >> ~/VulnProject/$IPADDRANGE
	echo "IP Address Online Currently"
	cat ~/VulnProject/$IPADDRANGE
	sleep 1
	
	}
		
##Call IP Range Scan Function
SCANIPRANGE
	
##Function to Find All Open TCP Ports	
		function PORTS ()
		{
		OPENPORTS=Nmap_Open_Ports_$TIMESTAMP.txt
		#screen TCP ports for service and open ports

			echo "Nmap Command Used: sudo nmap $IPS --open -sV -O -p-"  >> ~/VulnProject/$IPS/$OPENPORTS
			sudo nmap $IPS --open -sV -O -p- >> ~/VulnProject/$IPS/$OPENPORTS
		#Screen service version from masscan result
			echo "Nmap Command Used: sudo nmap $IPS --open -sU -sV -p $LINESU"  >> ~/VulnProject/$IPS/$OPENPORTS
			sudo nmap $IPS --open -sU -sV -p $LINESU >> ~/VulnProject/$IPS/$OPENPORTS
			

		}

##Function to Find All Open UDP Ports	
		function UPORTS ()
		{
		OPENPORTS=Nmap_Open_Ports_$TIMESTAMP.txt
		echo "Starting Open Ports and Script scan for $IPS"
			echo "sudo masscan --open -pu:1-65535 $IPS --rate=1000"  >> ~/VulnProject/$IPS/UDP_$OPENPORTS
			sudo masscan --open -pu:1-65535 $IPS --rate=1000 >> ~/VulnProject/$IPS/UDP_$OPENPORTS
		}

		
##Function to Run Scripts on Open Ports
				function SCRIPTRUN ()
		{
			echo "Nmap Command Used: sudo nmap $IPS -sV --script vulners --script-args vulscandb=exploitdb.csv -O -p $LINES2 "  >> ~/VulnProject/$IPS/Scripts_$OPENPORTS
			sudo nmap $IPS -sV --script=vulscan/vulscan.nse --script-args vulscandb=exploitdb.csv -O -p $LINES2 >> ~/VulnProject/$IPS/Scripts_$OPENPORTS
			echo "Nmap Command Used: sudo nmap $IPS -sU -sV --script vulners --script-args vulscandb=exploitdb.csv -p $LINESU "  >> ~/VulnProject/$IPS/Scripts_$OPENPORTS
			sudo nmap $IPS -sU -sV --script=vulscan/vulscan.nse --script-args vulscandb=exploitdb.csv -p $LINESU >> ~/VulnProject/$IPS/Scripts_$OPENPORTS
		}
		
##Function - Hydra to Check Weak Username/Passwords If Service Has SMB,SSH,TELNET,FTP
			function WEAK ()
		{		
			echo "Starting Weak User/Password Scan for $IPS"
			while read HYDRARUN;
				do
				SMB=$(echo $HYDRARUN | grep -i 'smb\|445\|139')
				SSH=$(echo $HYDRARUN | grep -i ssh)
				TELNET=$(echo $HYDRARUN | grep -i telnet)
				FTP=$(echo $HYDRARUN | grep -i ftp)

						if [ -z "$SMB" ];
						then
						:
						
						
						else
						HYDRAPORT=$(echo $HYDRARUN | grep -i 'smb\|445\|139' | tr "/" " " | awk '{print $1}')
						echo "working"
						echo "Screening SMB for weak pass, Command used hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt smb://$IPS:$HYDRAPORT" >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt smb://$IPS:$HYDRAPORT >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						
						
						if [ -z "$SSH" ];
						then
						:

						else
						HYDRAPORT=$(echo $HYDRARUN | grep -i ssh | tr "/" " " | awk '{print $1}')
						echo "Screening SSH for weak pass, Command used hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt ssh://$IPS:$HYDRAPORT" >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt ssh://$IPS:$HYDRAPORT >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						
						
						if [ -z "$TELNET" ];
						then
						:
						
						else
						HYDRAPORT=$(echo $HYDRARUN | grep -i telnet | tr "/" " " | awk '{print $1}')
						echo "Screening TELNET for weak pass, Command used hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt telnet://$IPS:$HYDRAPORT" >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt telnet://$IPS:$HYDRAPORT >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						
						
						if [ -z "$FTP" ];
						then
						:

						else
						
						HYDRAPORT=$(echo $HYDRARUN | grep -i ftp | tr "/" " " | awk '{print $1}')
						echo "Screening FTP for weak pass, Command used hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt ftp://$IPS:$HYDRAPORT" >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						hydra -L ~/VulnProject/Wordlists/top-usernames-shortlist.txt -P ~/VulnProject/Wordlists/2020-200_most_used_passwords.txt ftp://$IPS:$HYDRAPORT >> ~/VulnProject/$IPS/Weakpasses_$TIMESTAMP.txt
						
				
					fi
					fi
					fi
					fi


									
				done < $PORTRANGE 
			}
			
##For Loop To Seprate Results Into Their Relavent Folder/Files	
			
##start Nmap/Script scan and hydra for specific IP
		RANGE=~/VulnProject/$IPADDRANGE
		LINES=$(cat $RANGE)
		for IPS in $LINES;
			do
			mkdir ~/VulnProject/$IPS 2>/dev/null
			echo $IPS > ~/VulnProject/$IPS/$IPS.txt
			#Start Running Port UDP scan function
			UPORTS
			PORTRANGEU=~/VulnProject/$IPS/UDP_$OPENPORTS
			LINESU=$(cat $PORTRANGEU | grep -i open | tr "/" " " | awk '{print $4}' | grep -o '[[:digit:]]*' | tr '\n' ',')
			
			#Start Running Port TCP n UDP scan function
			PORTS
			
				PORTRANGE=~/VulnProject/$IPS/$OPENPORTS
				LINES2=$(cat $PORTRANGE | grep -i open | grep -i tcp | tr "/" " " | awk '{print $1}' | grep -o '[[:digit:]]*' | tr '\n' ',')
				#Start Running Script scan function
				SCRIPTRUN
			
				#Activate While loop for hydra scans
				WEAK

				done
			
			echo -ne "$BOLD$RED
			Scans completed, please find the results in their respective sub-directory located in ~/VulnProject $RESET"
		
	



				
				
