#!/bin/bash

# Colors to make things pretty
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

# Resets cursor in case ctrl-c is called mid cursor off
function ctrl_c() {
        setterm -cursor on
}
 
# Used for long waits while longer commands execute
spinner() {
	PID=$!
	i=1
	sp="/-\|"
	setterm -cursor off
	while [ -d /proc/$PID ]
	do
		printf "\b${sp:i++%${#sp}:1}"
		sleep .25
	done
	setterm -cursor on
	printf "\b "
}

# Echo usage to let user know how to use
usage() { 
	echo -e "Usage: bt [-c <device name>] [-d <device name>] [-l] [-i] [-s <seconds>]"
	echo -e "\t${BOLD}-c  ${NOCOLOR}Connect to the specific bt device"
	echo -e "\t${BOLD}-d  ${NOCOLOR}Disconnect from the specific bt device"
	echo -e "\t${BOLD}-l  ${NOCOLOR}List all available bt devices"
	echo -e "\t${BOLD}-i  ${NOCOLOR}Display all paired bt devices"
	echo -e "\t${BOLD}-s  ${NOCOLOR}Scan for new bt devices"
	exit 1
}

# Determine bt device name/addr and check to see if valid
setDeviceNameAndAddr() {
	bt_addr=$(bluetoothctl devices | grep -iF ${arg1,,} | awk '{print $2}')
	bt_name=$(bluetoothctl devices | grep -iF ${arg1,,} | cut -d' ' -f3-)
	
	# Check to see if device name is invalid
	if [ -z "$bt_addr" ] ; then
		echo "ERROR: Could not find valid device name"
		usage
		exit
	fi
}

# Obtain options and their arguments
while getopts ":c:d:s:lipt" o; do
	case "${o}" in
		c) # Connect bt device
			arg1=${OPTARG}
			option="connect"
			;;
		d) # Disconnect bt device
			arg1=${OPTARG}
			option="disconnect"
			;;
		s) # Scan for bt devices
			arg1=${OPTARG}
			option="scan"
			;; 
		l) # List all bt devices
			echo -e "Available bt devices: ${BLUE}"
			bluetoothctl devices | cut -d' ' -f3-
			exit
			;;
		i|p) # List currently paired bt devices
			# Determine what devices are paired
			connected=$(bluetoothctl paired-devices | cut -d' ' -f3-)
			
			# Display error if not paired to a bt device
			if [ -z "$connected" ] ; then
				echo "ERROR: No bt devices currently paired"
				usage
			else
				# Display bt device info if paired devices found
				echo -e "Paired bt devices: "
				echo -e "${YELLOW}$connected"
			fi
			exit
			;;
		t) # Test bt audio playback
			echo -n "Testing bt device audio playback... " 
			aplay /usr/share/sounds/sound-icons/start &> /dev/null & spinner
			echo "Test complete!"
			exit
			;;
		:) # Error if no argument provided for required option
			echo "ERROR: Option -$OPTARG requires an argument"
			usage
			;;
		\?) # For everything else
			echo "ERROR: Invalid option -$OPTARG"
			usage
			;;
	esac
done

# Check required switches exist
if [ -z "${arg1,,}" ] ; then
	usage
fi

# Determine what to do based on $option selected by user
if [ $option = "connect" ]
then
	# Grab bt device name/addr to help connect to bt device stated in the -c argument
	setDeviceNameAndAddr
	
	# Connect to bt device
	echo -e "Connecting to ${YELLOW}$bt_name ${NOCOLOR}($bt_addr)..."
	bluetoothctl connect $bt_addr
elif [ $option = "disconnect" ]
then
	# Grab bt device name/addr to help connect to bt device stated in the -d argument
	setDeviceNameAndAddr
	
	echo -e "Disconnecting from ${YELLOW}$bt_name ${NOCOLOR}($bt_addr)..."
	bluetoothctl disconnect $bt_addr
	
elif [ $option = "scan" ]
then
	# Determine if arg1 input is a #,
	if [ -n "$arg1" ] && [ "$arg1" -eq "$arg1" ] 2>/dev/null; then
		# Scan and display new bt devices
		echo -en "Scanning for new BT devices for ${YELLOW}$arg1${NOCOLOR} second(s)... "
		{   printf 'scan on\n\n'
		    sleep $arg1
		    printf 'devices\n\n'
		    printf 'quit\n\n'
		} | bluetoothctl &> /dev/null & spinner
			
		echo -en "\nScan complete. Devices found:${BLUE}\n"
		bluetoothctl devices
	else
		# -s argument was not a valid number
		echo "ERROR: Option -s requires a valid number"
		usage
		exit 1
	fi
else
	# Catch-all for -c/-d
	echo "ERROR: Could not find valid device name"
	usage
fi


