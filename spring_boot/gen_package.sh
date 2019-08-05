#!/bin/bash

#############################################################
#           JAR Server Generate Package Script              #
#############################################################

# Print JAR Server Logo
echo " ____"
echo "/ ___|  ___ _ ____   _____ _ __"
echo "\\___ \\ / _ \\ '__\\ \\ / / _ \\ '__|"
echo " ___) |  __/ |   \\ V /  __/ |"
echo "|____/ \\___|_|    \\_/ \\___|_|"
echo ""

# Parse current absolute path
CURRENT_RELATIVE_PATH=`pwd | awk -F / '{ print $(NF-1)"/"$NF; }'`

# Check current relative path
if [ ! "${CURRENT_RELATIVE_PATH}" = "jarServer/setup" ]; then
	echo ""
	echo "Please, run this script from /jarServer/setup directory..."
	echo ""
	exit 1
fi

echo "Getting JAR Server JAR File"
cp -v ../target/jar-*.jar ./.
echo ""

if [ ! -f ./jar-*.jar ]; then
    echo "JAR Server JAR FIle not found..."
	echo "Trying to compile project..."
	sleep 1

	# Trying to compile project
	cd ../
	mvn clean install
	cd -

	echo "Getting JAR Server JAR File"
	cp -v ../target/jar-*.jar ./.
	echo ""

	if [ ! -f ./jar-*.jar ]; then
		echo ""
		echo "JAR Server JAR FIle not found..."
		echo "Fail to generate jar-server-package.tar.gz"
		echo ""
		exit 1
	fi
fi

echo "Creating jar-server-package directory"
mkdir -v jar-server-package
echo ""

echo "Adding Files to jar-server-package"
cp -rfv JARServerConfig jar-server-package
cp -v 000-default.conf jar-server-package
cp -v jar-install.sh jar-server-package
cp -v jar-server jar-server-package
cp -v jar-*.jar jar-server-package
echo ""

echo "Compressing jar-server-package directory"
tar -zcvf jar-server-package.tar.gz jar-server-package
echo ""

echo "Removing temporary files..."
rm -vrf jar-server-package
echo ""

# End
echo "JAR Server Package Generation Done!"
echo ""

exit 0

