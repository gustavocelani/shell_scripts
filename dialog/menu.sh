#!/bin/bash

# Define the dialog exit status codes
: ${DIALOG_CANCEL=1}
: ${DIALOG_ESC=255}

# Dialog Settings
HEIGHT=0
WIDTH=0
ROWS=10

# Display result env vairable on dialog message box
display_result()
{
	dialog \
		--title "$1" \
		--no-collapse \
		--msgbox "$result" ${HEIGHT} ${WIDTH}
}

# Main while
while true;
do
	# Duplicate file descriptor 1 on descreiptor 3
	exec 3>&1

	# Displaying Menu Dalog
	selection=$(dialog \
		--backtitle "System Information Dialog Script" \
		--title "Menu" \
		--clear \
		--ok-label "OK" \
		--cancel-label "Exit" \
		--menu "Please select:" ${HEIGHT} ${WIDTH} ${ROWS} \
			"1"  "Host Information" \
			"2"  "File System Information" \
			"3"  "Kernel Information" \
			"4"  "CPU Information" \
			"5"  "Memory Information" \
			"6"  "Cryptography Information" \
			"7"  "Control Groups Information" \
			"8"  "Devices Information" \
			"9"  "Disk Information" \
			"10" "Partitions Information" \
		2>&1 1>&3)

	# Get the exit status
	exit_status=$?

	# Close file descriptor 3
	exec 3>&-

	# Clearing Dialog Env
	clear

	# Check cancel actions
	case $exit_status in
		$DIALOG_CANCEL)
			printf "\nProgram terminated.\n\n"
			exit
			;;
		$DIALOG_ESC)
			printf "\nProgram aborted.\n\n" >&2
			exit 1
		;;
	esac

	# Check Selection
	case $selection in
		0)
			printf "\nProgram terminated.\n\n"
		;;
		1)
			result=$( \
				echo "Hostname: ${HOSTNAME}" ;\
				printf "Up Time: "; uptime -p)
			display_result "Host Information"
		;;
		2)
			result=$(df -h)
			display_result "File System Information"
		;;
		3)
			result=$(\
				printf "OS: "; uname ;\
				printf "OS Version: "; cat /proc/version_signature ;\
				printf "Kernel Version: "; uname -r)
			display_result "Kernel Information"
		;;
		4)
			result=$(cat /proc/cpuinfo)
			display_result "CPU Information"
		;;
		5)
			result=$(cat /proc/meminfo)
			display_result "Memory Information"
		;;
		6)
			result=$(cat /proc/crypto)
			display_result "Cryptography Information"
		;;
		7)
			result=$(cat /proc/cgroups)
			display_result "Control Groups Information"
		;;
		8)
			result=$(cat /proc/devices)
			display_result "Devices Information"
		;;
		9)
			result=$(cat /proc/diskstats)
			display_result "Disk Information"
		;;
		10)
			result=$(cat /proc/partitions)
			display_result "Partitions Information"
		;;
	esac
done

