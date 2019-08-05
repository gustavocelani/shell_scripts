#!/bin/bash

#############################################################
#               JAR Server Install Script                   #
#############################################################

# Workspace Absolute Path
WORKSPACE_PATH="/home/ubuntu/JAR_Server_Workspace"

#
# Print JAR Server Logo
#
print_logo()
{
	echo " ____"
	echo "/ ___|  ___ _ ____   _____ _ __"
	echo "\\___ \\ / _ \\ '__\\ \\ / / _ \\ '__|"
	echo " ___) |  __/ |   \\ V /  __/ |"
	echo "|____/ \\___|_|    \\_/ \\___|_|"
	echo ""
}

# Starting
print_logo
echo "Starting to install JAR Server setup..."
echo ""

# Recommended Setup
echo "Recommended AWS Instance Configurations:"
echo "* Instance............. ec-2"
echo "* Instance type........ t3.small"
echo "* Operational Sysem.... Ubuntu Server 18.04"
echo ""

# Installing Open JDK
echo "Attempt to install OpenJDK 8..."
sudo apt-get install openjdk-8-jre-headless
echo ""

# Installing MongoDB
echo "Setting up KeyServer"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "Attempt to add MongoDB repository..."
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

echo "Updating..."
sudo apt-get update

echo "Attempt to install MongoDB..."
sudo apt-get install -y mongodb-org
echo ""

# Installing Apache2
echo "Attempt to install Apache2..."
sudo apt-get install apache2

echo "Attempt to setting up Proxy..."
sudo a2enmod proxy

echo "Attempt to setting up HTTP Proxy..."
sudo a2enmod proxy_http

echo "Replacing Apache2 Default VirtualHost Proxy file..."
sudo cp -v ${WORKSPACE_PATH}/000-default.conf /etc/apache2/sites-enabled/000-default.conf

echo "Attempt to restart Apache2 Service"
sudo service apache2 restart
echo ""

# JAR Server Config Files
echo "Setting up JAR Server Config Files"
sudo cp -vrf ${WORKSPACE_PATH}/JARServerConfig/ /home/.
echo ""

# JAR Server Controller Script
echo "Setting up JAR Server Controller Script..."
sudo cp -v ${WORKSPACE_PATH}/jar-server /bin/
echo ""

# End
echo "JAR Server Install Done!"
echo ""

# JAR Server Help menu
jar-server

exit 0

