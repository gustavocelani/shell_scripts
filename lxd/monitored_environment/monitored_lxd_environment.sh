#!/bin/bash

###############################################################################
#
#       Filename:  monitored_lxd_environment.sh
#
#    Description:  Monitored LXD Environment General Script.
#                  Run as super user.
#
#        Version:  1.0
#        Created:  08/10/2019 17:12:36 PM
#       Revision:  1
#
#         Author:  Gustavo P de O Celani
#
################################################################################


# Container Names
NAME_BASE="debian9padrao"
NAME_WWW1="www1"
NAME_WWW2="www2"
NAME_LOG="log"
NAME_GERENCIA="gerencia"
NAME_PROXY="proxy"
NAME_SSH="ssh"
NAME_FIREWALL="firewall"

# Network Names
NETWORK_DMZ="networkDMZ"
NETWORK_SERVERS="networkServers"
NETWORK_WEB="networkWeb"


#
# Print Logo
#
print_logo()
{
    echo ""
    echo " ___ _   _ _____   ____ _____ _  _   "
    echo "|_ _| \\ | |  ___| | ___|___  | || |  "
    echo " | ||  \\| | |_    |___ \\  / /| || |_ "
    echo " | || |\\  |  _|    ___) |/ / |__   _|"
    echo "|___|_| \\_|_|     |____//_/     |_|  "
    echo ""
}


#
# Generates a Debian Base Container
#
generate_container_base()
{
    clear
    print_logo

    echo ""
	echo "Generate Container ${NAME_BASE}"

    echo "Initializing [ ${NAME_BASE} ] with Debian Stretch"
    lxc init images:debian/stretch ${NAME_BASE}

    start_container ${NAME_BASE}

    echo ""
    for COUNT in {9..0}; do printf "\rWaiting to [ ${NAME_BASE} ] start... [ %02d ]" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Updating [ ${NAME_BASE} ]"
    lxc exec ${NAME_BASE} -- /usr/bin/apt update

    echo ""
    echo "Installing custom packages on [ ${NAME_BASE} ]"
    lxc exec ${NAME_BASE} -- /usr/bin/apt install -y tcpdump apt-utils aptitude net-tools inetutils-ping traceroute iptables htop bind9-host dnsutils rsyslog links vim

    echo ""
    echo "Setting up timezone to [ America/Sao_Paulo ]"
    lxc exec ${NAME_BASE} -- timedatectl set-timezone "America/Sao_Paulo"

    power_off_container ${NAME_BASE}
}


#
# Generate Networks
#
generate_networks()
{
    clear
    print_logo

	echo ""
	echo "Generate Networks"

    echo ""
    echo "Generating network [ ${NETWORK_DMZ} ] ..."
    lxc network create ${NETWORK_DMZ} ipv6.address=2001:db8:574:A::1/64 ipv4.address=10.0.10.1/24 ipv4.nat=false ipv4.dhcp=false

    echo "Generating network [ ${NETWORK_SERVERS} ] ..."
    lxc network create ${NETWORK_SERVERS} ipv6.address=2001:db8:574:B::1/64 ipv4.address=10.0.20.1/24 ipv4.nat=false ipv4.dhcp=false

    echo "Generating network [ ${NETWORK_WEB} ] ..."
    lxc network create ${NETWORK_WEB} ipv6.address=2001:db8:574:C::1/64 ipv4.address=10.0.30.1/24 ipv4.nat=false ipv4.dhcp=false
}


#
# Generate Container Firewall
#
generate_container_firewall()
{
    clear
    print_logo

	echo ""
	echo "Generate Container ${NAME_FIREWALL}"

    echo ""
    echo "Cloning [ ${NAME_BASE} ] to [ ${NAME_FIREWALL} ]"
    lxc copy ${NAME_BASE} ${NAME_FIREWALL}

    echo ""
    echo "Attaching network [ ${NETWORK_DMZ} ] on interface [ eth1 ]"
    lxc network attach ${NETWORK_DMZ} ${NAME_FIREWALL} eth1

    echo "Attaching network [ ${NETWORK_SERVERS} ] on interface [ eth2 ]"
    lxc network attach ${NETWORK_SERVERS} ${NAME_FIREWALL} eth2

    echo "Attaching network [ ${NETWORK_WEB} ] on interface [ eth3 ]"
    lxc network attach ${NETWORK_WEB} ${NAME_FIREWALL} eth3

    start_container ${NAME_FIREWALL}
    for COUNT in {9..0}; do printf "\rWaiting to [ ${NAME_FIREWALL} ] start... [ %02d ]" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Pushing configuration files..."
    echo "./conf/${NAME_FIREWALL}/interfaces    --->   ${NAME_FIREWALL}/etc/network/interfaces"
    lxc file push ./conf/${NAME_FIREWALL}/interfaces ${NAME_FIREWALL}/etc/network/interfaces
    echo "./conf/${NAME_FIREWALL}/sysctl.conf   --->   ${NAME_FIREWALL}/etc/sysctl.conf"
    lxc file push ./conf/${NAME_FIREWALL}/sysctl.conf ${NAME_FIREWALL}/etc/sysctl.conf
    echo "./conf/${NAME_FIREWALL}/rc.local      --->   ${NAME_FIREWALL}/etc/rc.local"
    lxc file push ./conf/${NAME_FIREWALL}/rc.local ${NAME_FIREWALL}/etc/rc.local

    echo ""
    echo "Rebooting ${NAME_FIREWALL}"
    lxc exec ${NAME_FIREWALL} -- reboot
}


#
# Generate Default Container
#
# $1: Container Name
# $2: Network Name to be attached on eth0 interface
#
generate_default_container()
{
    clear
    print_logo

    echo ""
	echo "Generate Container $1"

    echo ""
    echo "Cloning [ ${NAME_BASE} ] to [ $1 ]"
    lxc copy ${NAME_BASE} $1

    echo ""
    echo "Attaching network [ $2 ] on interface [ eth0 ]"
    lxc network attach $2 $1 eth0

    start_container $1
    for COUNT in {9..0}; do printf "\rWaiting to [ $1 ] start... [ %02d ]" "$COUNT"; sleep 1; done; echo ""

    echo ""
    echo "Pushing configuration files..."
    echo "./conf/$1/interfaces    --->   $1/etc/network/interfaces"
    lxc file push ./conf/$1/interfaces $1/etc/network/interfaces

    echo ""
    echo "Rebooting [ $1 ]"
    lxc exec $1 -- reboot
}

#
# Removes a container
# $1: Container Name
#
remove_container()
{
    clear
    print_logo

    power_off_container $1
    for COUNT in {5..0}; do printf "\rWaiting to [ $1 ] power off... [ %02d ]" "$COUNT"; sleep 1; done; echo ""

    echo "Removing [ $1 ]"
    lxc delete $1
}


#
# Removes a network
# $1: Network Name
#
remove_network()
{
    clear
    print_logo

    echo "Removing [ $1 ]"
    lxc network delete $1
}


#
# Power off a Container
# $1 Container Name
#
power_off_container()
{
    echo ""
    echo "Turning off [ $1 ]"
    lxc exec $1 -- /sbin/poweroff
}


#
# Start a Container
# $1 Container Name
#
start_container()
{
    echo ""
    echo "Starting [ $1 ]"
    lxc start $1
}


#
# List Environment
#
environment_list()
{
    echo ""
    read -p "Press enter to continue..."

    clear
    print_logo

    lxc list
    echo ""
    lxc network list

    echo ""
    read -p "Press enter to continue..."
}


#
# Remove Environment
#
remove_environment()
{
    clear
    print_logo

    echo ""
    echo "Remove Environment"

    remove_container ${NAME_FIREWALL}
    remove_container ${NAME_WWW1}
    remove_container ${NAME_WWW2}
    remove_container ${NAME_LOG}
    remove_container ${NAME_GERENCIA}
    remove_container ${NAME_SSH}
    remove_container ${NAME_PROXY}

    remove_network ${NETWORK_DMZ}
    remove_network ${NETWORK_SERVERS}
    remove_network ${NETWORK_WEB}
}


#
# Stop Environment
#
stop_environment()
{
    clear
    print_logo

    echo ""
    echo "Stop Environment"

    power_off_container ${NAME_FIREWALL}
    power_off_container ${NAME_WWW1}
    power_off_container ${NAME_WWW2}
    power_off_container ${NAME_LOG}
    power_off_container ${NAME_GERENCIA}
    power_off_container ${NAME_SSH}
    power_off_container ${NAME_PROXY}
}


#
# Start Environment
#
start_environment()
{
    clear
    print_logo

    echo ""
    echo "Start Environment"

    start_container ${NAME_FIREWALL}
    start_container ${NAME_WWW1}
    start_container ${NAME_WWW2}
    start_container ${NAME_LOG}
    start_container ${NAME_GERENCIA}
    start_container ${NAME_SSH}
    start_container ${NAME_PROXY}
}


################################################################################
# Main Loop
################################################################################
clear
print_logo


################################################################################
# Remove Environment
################################################################################
# remove_environment
# exit


################################################################################
# Stop Environment
################################################################################
# stop_environment
# exit


################################################################################
# Start Environment
################################################################################
# start_environment
# exit


################################################################################
# Generate Container Base
################################################################################
# generate_container_base
# exit


################################################################################
# Networks
################################################################################

#
# Generate Networks
#
# DMZ
# ===
# IPv4: 172.0.10.1/24
# IPv6: 2001:db8:574:A::1/64
#
# SERVERS
# =======
# IPv4: 172.0.20.1/24
# IPv6: 2001:db8:574:B::1/64
#
# WEB
# ===
# IPv4: 172.0.30.1/24
# IPv6: 2001:db8:574:C::1/64
#
generate_networks


################################################################################
# Firewall Container
################################################################################

#
# Generate Firewall Container
# Check network information on [ ./conf/firewall/interfaces ]
#
# eth0
# ====
# DHCP
#
# eth1
# ====
# Network: DMZ
# IPv4:    172.0.10.100/24
# IPv6:    2001:db8:574:A::100/64
#
# eth2
# ====
# Network: SERVERS
# IPv4:    172.0.20.100/24
# IPv6:    2001:db8:574:B::100/64
#
# eth3
# ====
# Network: WEB
# IPv4:    172.0.30.100/24
# IPv6:    2001:db8:574:B::100/64
#
generate_container_firewall


################################################################################
# Network: WEB
################################################################################

#
# Generate Container www1
# Check network information on [ ./conf/www1/interfaces ]
#
# eth0
# ====
# Network: WEB
# IPv4:    172.0.30.10/24
# IPv6:    2001:db8:574:C::10/64
#
generate_default_container ${NAME_WWW1} ${NETWORK_WEB}

#
# Generate Container www2
# Check network information on [ ./conf/www2/interfaces ]
#
# eth0
# ====
# Network: WEB
# IPv4:    172.0.30.20/24
# IPv6:    2001:db8:574:C::20/64
#
generate_default_container ${NAME_WWW2} ${NETWORK_WEB}


################################################################################
# Network: SERVERS
################################################################################

#
# Generate Container Log
# Check network information on [ ./conf/log/interfaces ]
#
# eth0
# ====
# Network: SERVERS
# IPv4:    172.0.20.10/24
# IPv6:    2001:db8:574:B::10/64
#
generate_default_container ${NAME_LOG} ${NETWORK_SERVERS}

#
# Generate Container Gerencia
# Check network information on [ ./conf/gerencia/interfaces ]
#
# eth0
# ====
# Network: SERVERS
# IPv4:    172.0.20.20/24
# IPv6:    2001:db8:574:B::20/64
#
generate_default_container ${NAME_GERENCIA} ${NETWORK_SERVERS}


################################################################################
# Network: DMZ
################################################################################

#
# Generate Container SSH
# Check network information on [ ./conf/ssh/interfaces ]
#
# eth0
# ====
# Network: DMZ
# IPv4:    172.0.10.10/24
# IPv6:    2001:db8:574:A::10/64
#
generate_default_container ${NAME_SSH} ${NETWORK_DMZ}

#
# Generate Container Proxy
# Check network information on [ ./conf/proxy/interfaces ]
#
# eth0
# ====
# Network: DMZ
# IPv4:    172.0.10.20/24
# IPv6:    2001:db8:574:A::20/64
#
generate_default_container ${NAME_PROXY} ${NETWORK_DMZ}


################################################################################
# Environment
################################################################################

environment_list
echo ""
