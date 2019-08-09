#!/bin/bash

###############################################################################
#
#       Filename:  simple_lxd_environment.sh
#
#    Description:  Simple LXD Environment General Script.
#                  Run as super user.
#
#       Features:  - Generate Base Debian Container
#                  - Generate Router and Networks
#                  - Generate Clones from Base Debian Container
#                  - Remove Containers
#                  - Test Containers
#                  - List Containers
#
#       Packages:  - lxd
#                  - dialog
#
#        Version:  1.0
#        Created:  07/08/2019 20:58:06 PM
#       Revision:  1
#
#         Author:  Gustavo P de O Celani
#
################################################################################

# Container Names
BASE_NAME="DebianBase"
A1_NAME="A1"
A2_NAME="A2"
B1_NAME="B1"
R_NAME="R"

# Network Names
NETWORK_AR="redeAR"
NETWORK_BR="redeBR"

# Define the dialog exit status codes
: ${DIALOG_CANCEL=1}
: ${DIALOG_ESC=255}

# Dialog Settings
HEIGHT=0
WIDTH=0
ROWS=8

#
# Print Logo
#
print_logo()
{
    echo ""
    echo "              _    __  ______  "
    echo "             | |   \\ \\/ /  _ \\ "
    echo "             | |    \\  /| | | |"
    echo "             | |___ /  \\| |_| |"
    echo "             |_____/_/\\_\\____/"
    echo "  ____            _        _                 "
    echo " / ___|___  _ __ | |_ __ _(_)_ __   ___ _ __ "
    echo "| |   / _ \\| '_ \\| __/ _\` | | '_ \\ / _ \\ '__|"
    echo "| |__| (_) | | | | || (_| | | | | |  __/ |   "
    echo " \\____\\___/|_| |_|\\__\\__,_|_|_| |_|\\___|_|"
    echo ""
    echo ""
}

#
# Display message on dialog message box
# $1: Title
# $2: Message
#
display_on_dialog()
{
	dialog \
		--title "$1" \
		--no-collapse \
		--msgbox "$2" ${HEIGHT} ${WIDTH}
}

#
# Generates a Debian Base Container
#
generate_base_container()
{
    clear
    print_logo

    echo "Initializing [ ${BASE_NAME} ] with Debian Stretch"
    lxc init images:debian/stretch ${BASE_NAME}

    echo "Starting [ ${BASE_NAME} ]"
    lxc start ${BASE_NAME}

    echo ""
    for COUNT in {15..0}; do printf "\rWaiting to [ ${BASE_NAME} ] start... %02d" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Updating [ ${BASE_NAME} ]"
    lxc exec ${BASE_NAME} -- /usr/bin/apt update

    echo ""
    echo "Installing custom packages on [ ${BASE_NAME} ]"
    lxc exec ${BASE_NAME} -- /usr/bin/apt install -y tcpdump apt-utils aptitude net-tools inetutils-ping tracerout iptables htop bind9-host dnsutils rsyslog links man vim openssh-server

    echo ""
    echo "Setting up timezone to [ America/Sao_Paulo ]"
    lxc exec ${BASE_NAME} -- timedatectl set-timezone "America/Sao_Paulo"

    echo ""
    echo "Powering Off [ ${BASE_NAME} ]"
    lxc exec ${BASE_NAME} -- /sbin/poweroff
}

#
# Generates a router container
#
generate_router_container()
{
    clear
    print_logo

    echo "Creating network ${NETWORK_AR}..."
    lxc network create ${NETWORK_AR} ipv6.address=2001:db8:2018:A::1/64 ipv4.address=10.10.10.1/24 ipv4.nat=false ipv4.dhcp=false
    echo "Creating network ${NETWORK_BR}..."
    lxc network create ${NETWORK_BR} ipv6.address=2001:db8:2018:B::1/64 ipv4.address=10.10.20.1/24 ipv4.nat=false ipv4.dhcp=false

    echo ""
    echo "Cloning [ ${BASE_NAME} ] to [ ${R_NAME} ]"
    lxc copy ${BASE_NAME} ${R_NAME}

    echo ""
    echo "Attaching network [ ${NETWORK_AR} ] on interface [ eth1 ]"
    lxc network attach ${NETWORK_AR} ${R_NAME} eth1
    echo "Attaching network [ ${NETWORK_BR} ] on interface [ eth2 ]"
    lxc network attach ${NETWORK_BR} ${R_NAME} eth2

    echo "Starting [ ${R_NAME} ]"
    lxc start ${R_NAME}
    for COUNT in {15..0}; do printf "\rWaiting to [ ${R_NAME} ] start... %02d" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Pushing configuration files..."
    echo "./conf/${R_NAME}/interfaces    --->   ${R_NAME}/etc/network/interfaces"
    lxc file push ./conf/${R_NAME}/interfaces ${R_NAME}/etc/network/interfaces
    echo "./conf/${R_NAME}/sysctl.conf   --->   ${R_NAME}/etc/sysctl.conf"
    lxc file push ./conf/${R_NAME}/sysctl.conf ${R_NAME}/etc/sysctl.conf
    echo "./conf/${R_NAME}/rc.local      --->   ${R_NAME}/etc/rc.local"
    lxc file push ./conf/${R_NAME}/rc.local ${R_NAME}/etc/rc.local
    echo "./conf/${R_NAME}/radvd.conf    --->   ${R_NAME}/etc/radvd.conf"
    lxc file push ./conf/${R_NAME}/radvd.conf ${R_NAME}/etc/radvd.conf

    echo ""
    echo "Installing radvd..."
    lxc exec ${R_NAME} -- /usr/bin/apt install -y radvd
    lxc exec ${R_NAME} -- /usr/sbin/update-rc.d radvd enable
}

#
# Generates a clone container from Base
# $1: Clone Container Name
# $2: Clone Container Network Name
#
generate_clone()
{
    clear
    print_logo

    echo "Cloning [ ${BASE_NAME} ] to [ $1 ]"
    lxc copy ${BASE_NAME} $1

    echo ""
    echo "Attaching network [ $2 ] on interface [ eth0 ]"
    lxc network attach $2 $1 eth0

    echo "Starting [ $1 ]"
    lxc start $1
    for COUNT in {15..0}; do printf "\rWaiting to [ $1 ] start... %02d" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Pushing configuration files..."
    echo "./conf/$1/interfaces    --->   $1/etc/network/interfaces"
    lxc file push ./conf/$1/interfaces $1/etc/network/interfaces


}

#
# Removes a container
# $1: Container Name
#
remove_container()
{
    clear
    print_logo

    echo "Send power off signal to [ $1 ]"
    lxc exec $1 -- /sbin/poweroff

    echo ""
    for COUNT in {9..0}; do printf "\rWaiting to $1 power off... %02d" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Removing [ $1 ]"
    lxc delete $1
}

#
# Removes all networks
#
remove_networks()
{
    clear
    print_logo

    echo "Removing network [ ${NETWORK_AR} ]"
    lxc network delete ${NETWORK_AR}
    echo "Removing network [ ${NETWORK_BR} ]"
    lxc network delete ${NETWORK_BR}
}

#
# Test environment network
#
test_environment_network()
{
    clear
    print_logo

    printf "Testing IPv4\n\n"
    lxc exec ${A1_NAME} -- /bin/ping -c 3 10.10.10.20
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping -c 3 10.10.10.100
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping -c 3 10.10.20.100
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping -c 3 10.10.20.10

    printf "\n\nTesting IPv6\n\n"
    lxc exec ${A1_NAME} -- /bin/ping6 -c 3 2001:db8:2018:A::20
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping6 -c 3 2001:db8:2018:A::100
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping6 -c 3 2001:db8:2018:B::100
    printf "\n\n"
    lxc exec ${A1_NAME} -- /bin/ping6 -c 3 2001:db8:2018:B::10

    sleep 3
}

#
# Main Loop
#
while true;
do
	exec 3>&1
	SELECTION=$(dialog \
		--backtitle "UNICAMP INF572 - TCP/IP Pratico II - Lab1" \
		--title "INF572 - Lab 1" \
		--clear \
		--ok-label "OK" \
		--cancel-label "Exit" \
		--menu "Actions:" ${HEIGHT} ${WIDTH} ${ROWS} \
			"1"  "Generate ${BASE_NAME}" \
			"2"  "Generate Environment" \
			" "  " " \
			"3"  "Remove ${BASE_NAME}" \
			"4"  "Remove Environment" \
			" "  " " \
			"5" "Test Environment Network" \
			"6" "List Environment Containers" \
		2>&1 1>&3)

	# Get the exit status and close file descriptor
	EXIT_STATUS=$?
	exec 3>&-

	# Check cancel actions
	case $EXIT_STATUS in
		$DIALOG_CANCEL)
			clear
			print_logo
			printf "\nProgram terminated.\n\n"
			exit 1
			;;
		$DIALOG_ESC)
			clear
			print_logo
			printf "\nProgram aborted.\n\n" >&2
			exit 1
		;;
	esac

	# Check Selection
	case $SELECTION in
		0)
			clear
			print_logo
			printf "\nProgram terminated.\n\n"
		;;
		1)
			clear
			print_logo
			generate_base_container
		;;
		2)
			generate_base_container
			generate_router_container
			generate_clone ${A1_NAME} ${NETWORK_AR}
			generate_clone ${A2_NAME} ${NETWORK_AR}
			generate_clone ${B1_NAME} ${NETWORK_BR}
			display_on_dialog "Generate Environment" "All Actions Done"
		;;
		3)
			clear
			print_logo
			remove_container ${BASE_NAME}
			display_on_dialog "Remove [ ${BASE_NAME} ]" "All Actions Done"
		;;
		4)
			clear
			print_logo
			remove_container ${BASE_NAME}
			remove_container ${R_NAME}
			remove_container ${A1_NAME}
			remove_container ${A2_NAME}
			remove_container ${B1_NAME}
			remove_networks
			display_on_dialog "Remove Environment" "All Actions Done"
		;;
		5)
			clear
			print_logo
			test_containers_network
			display_on_dialog "Test Environment Network" "All Actions Done"
		;;
		6)
			display_on_dialog "List Containers" $(lxc list)
		;;
	esac
done

