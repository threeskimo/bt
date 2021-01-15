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

# Used for long waits while longer commands execute
spinner() {
	PID=$!
	i=1
	sp="/-\|"
	while [ -d /proc/$PID ]
	do
		printf "\b${sp:i++%${#sp}:1}"
		sleep .25
	done
	printf "\b "
}

# Echo usage if something isn't right
usage() { 
	echo -e "Usage: bt [-c <device name>] [-d <device name>] [-l] [-i] [s <seconds>]"
	echo -e "\t${BOLD}-c ${NOCOLOR}Connect to the specific bt device name"
	echo -e "\t${BOLD}-d ${NOCOLOR}Disconnect the currently connected bt device"
	echo -e "\t${BOLD}-l ${NOCOLOR}List all available bt devices"
	echo -e "\t${BOLD}-i ${NOCOLOR}Display paired bt device"
	echo -e "\t${BOLD}-s ${NOCOLOR}Scan for new bt devices"
	exit 1
}

# Obtain options and their arguments
while getopts ":c:d:s:lipt" o; do
	case "${o}" in
		c) # Connect bt devices
			arg1=${OPTARG}
			option="connect"
			;;
		d) # Disconnect bt device
			arg1=${OPTARG}
			option="disconnect"
			;;
		s) # Scan for bt devices for X seconds
			arg1=${OPTARG}
			option="scan"
			;; 
		l) # List all bt devices
			echo -e "Available bt devices: ${BLUE}"
			bluetoothctl devices | cut -d' ' -f3-
			exit
			;;
		i|p) # List currently connected bt device name
			# Determine what devices are connected
			connected=$(bluetoothctl paired-devices | cut -d' ' -f3-)
			
			# Display error if not connected to a bt device
			if [ -z "$connected" ] ; then
				echo "ERROR: No bt device currently connected"
				usage
			else
				# Display bt device info if device found
				echo -e "Paired bt devices: "
				echo -e "${YELLOW}$connected"
			fi
			exit
			;;
		t) # Test bt playback
			echo -n "Testing bt device playback... " 
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
if [ $option = "connect" ]
then
	# Connect to the devices listed in the -c argument
	device=$(bluetoothctl devices | grep -iF ${arg1,,} | awk '{print $2}')
	deviceName=$(bluetoothctl devices | grep -iF ${arg1,,} | cut -d' ' -f3-)
	
	# Check to see if device name invalid
	if [ -z "$device" ] ; then
		echo "ERROR: Could not find valid device name"
		usage
		exit
	fi
	
	# Connect to bt device
	echo -e "Connecting to ${YELLOW}$deviceName ${NOCOLOR}($device)..."
	bluetoothctl connect $device
elif [ $option = "disconnect" ]
then
	# Connect to the devices listed in the -d argument
	device=$(bluetoothctl devices | grep -iF ${arg1,,} | awk '{print $2}')
	deviceName=$(bluetoothctl devices | grep -iF ${arg1,,} | cut -d' ' -f3-)

	# Check to see if device name invalid
	if [ -z "$device" ] ; then
		echo "ERROR: Could not find valid device name"
		usage
		exit
	fi
	
	echo -e "Disconnecting from ${YELLOW}$deviceName ${NOCOLOR}($device)..."
	bluetoothctl disconnect $device
	
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
	echo "ERROR: Could not find valid device name"
	usage
fi


