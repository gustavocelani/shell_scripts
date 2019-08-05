#!/bin/bash

#############################################################
#              Certificates Generator Script                #
#############################################################

# Output Directory
OUTPUT_DIR="Certificates"
# Output Path
OUTPUT_PATH="./${OUTPUT_DIR}"

# Log Tag
LOG_TAG="[LOG]"
# Separator
SEPARATOR="\n==========================================================================\n"

# Certificate Authority Base Name
ROOT_CA_BASE_NAME="SERVER_CA"
# Server Base Name
SERVER_BASE_NAME="Server_Name"

# Root Certificate Authority Key Name
ROOT_CA_KEY="${ROOT_CA_BASE_NAME}.key"
# Root Certificate Authority Name
ROOT_CA_CRT="${ROOT_CA_BASE_NAME}.crt"
# Server Certificate Key Name
SERVER_KEY="${SERVER_BASE_NAME}.key"
# Server Certificate Sign Request (CSR) Name
SERVER_CSR="${SERVER_BASE_NAME}.csr"
# Server Certificate Name
SERVER_CRT="${SERVER_BASE_NAME}.crt"

# Root Certificate Authority Expiration Days (Default: 1024)
ROOT_CA_EXPIRE_DAYS=1024
# Root Certificate Authority RSA Key Size (Default: 2048)
ROOT_CA_RSA_KEY_SIZE=2048

# Root Keystore Name
ROOT_KEYSTORE="${ROOT_CA_BASE_NAME}_Keystore.p12"
# Root Trust Store Name
ROOT_CA_TRUSTSTORE="${ROOT_CA_BASE_NAME}_TrustStore.jks"
# Root Certificate Authority Alias
ROOT_CA_ALIAS="${ROOT_CA_BASE_NAME}_CRT"

# Server Certificate Expiration Days (Default: 512)
SERVER_EXPIRE_DAYS=512
# Server Certicate RSA Key Size (Default: 2048)
SERVER_RSA_KEY_SIZE=2048

# Server Keystore Name
SERVER_KEYSTORE="${SERVER_BASE_NAME}_Keystore.p12"
# Server Certificate Alias
SERVER_CRT_ALIAS="${SERVER_BASE_NAME}_CRT"

#
# This config file is used to generate Server Certificate
# [server.csr.cnf]
# Fill your own data here
#
SERVER_CSR_CNF="
[req]\n
default_bits = ${SERVER_RSA_KEY_SIZE}\n
prompt = no\n
default_md = sha256\n
distinguished_name = dn\n
\n
[dn]\n
C=BR\n
ST=Sao Paulo\n
L=Campinas\n
O=Private\n
OU=Private\n
emailAddress=server_name@domain.com\n
CN=Server_Name\n
"

#
# This config file is used to generate Server Certificate
# [v3.cnf]
# Fill your own data here
#
V3_EXT="
authorityKeyIdentifier=keyid,issuer\n
basicConstraints=CA:FALSE\n
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n
subjectAltName = @alt_names\n
\n
[alt_names]\n
DNS.1 = localhost\n
DNS.2 = server_name.com\n
IP.1 = 192.168.9.9\n
"

# Print Logo
echo ""
echo "  ____          _   _  __ _           _"
echo " / ___|___ _ __| |_(_)/ _(_) ___ __ _| |_ ___"
echo "| |   / _ \\ '__| __| | |_| |/ __/ _\` | __/ _ \\"
echo "| |__|  __/ |  | |_| |  _| | (_| (_| | ||  __/"
echo " \\____\\___|_|   \\__|_|_| |_|\\___\\__,_|\\__\\___|"
echo "  ____                           _"
echo " / ___| ___ _ __   ___ _ __ __ _| |_ ___  _ __"
echo "| |  _ / _ \\ '_ \\ / _ \\ '__/ _\` | __/ _ \\| '__|"
echo "| |_| |  __/ | | |  __/ | | (_| | || (_) | |"
echo " \\____|\\___|_| |_|\\___|_|  \\__,_|\\__\\___/|_|"
echo ""

# Output Settings
if [ ! -d ${OUTPUT_PATH} ]; then
	echo "${LOG_TAG} Generating output directory"
	mkdir -v ${OUTPUT_PATH}
else
	echo "${LOG_TAG} The Output Path already Exists!"
fi

# Enter on Output Path
cd ${OUTPUT_PATH}
echo ""

# Copy Root Certificate Authority Files to be Used as Temp Files
if [ -d ${ROOT_CA_BASE_NAME} ]; then
	echo "${LOG_TAG} Copy Root Certificate Authority as Temp File"
	cp -v ./${ROOT_CA_BASE_NAME}/* ./
fi

# Check if Root Certificate Authority Already Exists
if [ ! -f ./${ROOT_CA_KEY} -a ! -f ./${ROOT_CA_CRT} ]; then

	# Root Certificate Authority Key Generation
	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Generating Root RSA-${ROOT_CA_RSA_KEY_SIZE} Key [${ROOT_CA_KEY}]"
	echo ""
	openssl genrsa -des3 -out ${ROOT_CA_KEY} ${ROOT_CA_RSA_KEY_SIZE}

	# Root Certificate Authority Generation
	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Generating Root X509 SHA256 Self-Signed Certificate Authority Valid for ${ROOT_CA_EXPIRE_DAYS} Days [${ROOT_CA_CRT}]"
	echo ""
	openssl req -x509 -new -nodes -key ${ROOT_CA_KEY} -sha256 -days ${ROOT_CA_EXPIRE_DAYS} -set_serial 0x$(openssl rand -hex 19) -out ${ROOT_CA_CRT}

	# Root Certificate Authority Check
	echo -e "${SEPARATOR}"
	if [ ! -f ./${ROOT_CA_CRT} ]; then
		echo "${LOG_TAG} FAIL to generate Root Certificate Authority!"
		echo "${LOG_TAG} Check the script parameters and try again..."
		echo -e "${SEPARATOR}"
		exit 1
	fi
	echo "${LOG_TAG} Root Certificate Authority generated successfully!"

	# Exporting Root Certificate Authority to Keystore
	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Exporting Root Certificate Authority to PKCS12 Keystore [${ROOT_KEYSTORE}]"
	echo ""
	openssl pkcs12 -export -in ${ROOT_CA_CRT} -inkey ${ROOT_CA_KEY} -out ${ROOT_KEYSTORE}

	# Keystore Check
	echo -e "${SEPARATOR}"
	if [ ! -f ./${ROOT_KEYSTORE} ]; then
		echo "${LOG_TAG} FAIL to Generate Root Keystore!"
		echo "${LOG_TAG} Check the script parameters and try again..."
		echo -e "${SEPARATOR}"
		exit 1
	fi
	echo "${LOG_TAG} Root Keystore Generated successfully!"

	# Importing Root Certificate Authority to Trust Store
	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Exporting Root Certificate AUthority to Trust Store [${ROOT_CA_TRUSTSTORE}]"
	echo ""
	keytool -import -trustcacerts -alias ${ROOT_CA_ALIAS} -file ${ROOT_CA_CRT} -keystore ${ROOT_CA_TRUSTSTORE}

	# Trust Store Check
	echo -e "${SEPARATOR}"
	if [ ! -f ./${ROOT_CA_TRUSTSTORE} ]; then
		echo "${LOG_TAG} FAIL to Generate Root Certificate Authority Trust Store!"
		echo "${LOG_TAG} Check the script parameters and try again..."
		echo -e "${SEPARATOR}"
		exit 1
	fi
	echo "${LOG_TAG} Root Certificate Authority Trust Store Generated successfully!"

	# Print Root Certificate Authority
	echo -e "${SEPARATOR}"
	openssl x509 -text -noout -in ${ROOT_CA_CRT}

	# Finishing Root Keystore Generation
	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Root Keystore Generation Finished Succesfully"
	echo "${LOG_TAG} Keystore............ ${ROOT_KEYSTORE}"
	echo "${LOG_TAG} Trust Store......... ${ROOT_CA_TRUSTSTORE}"

else

	# Print Root Certificate Authority
	echo -e "${SEPARATOR}"
	openssl x509 -text -noout -in ${ROOT_CA_CRT}

	echo -e "${SEPARATOR}"
	echo "${LOG_TAG} Root Certificate Authority was Found!"
	echo "${LOG_TAG} [${ROOT_CA_KEY}]..........OK"
	echo "${LOG_TAG} [${ROOT_CA_CRT}]..........OK"
	echo "${LOG_TAG} They will be used on Server Certificate"
fi

# Server CSR Config File
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Generating Server Certificate Sign Request (CSR) Config File [server.csr.cnf]"
echo -e ${SERVER_CSR_CNF} > server.csr.cnf
echo ""
cat server.csr.cnf

# Generating Server CSR
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Generating SHA256 RSA ${SERVER_RSA_KEY_SIZE} Server CSR [${SERVER_CSR}]"
echo ""
openssl req -new -sha256 -nodes -out ${SERVER_CSR} -set_serial 0x$(openssl rand -hex 19) -newkey rsa:${SERVER_RSA_KEY_SIZE} -keyout ${SERVER_KEY} -config <( cat server.csr.cnf )

# Server CSR Check
echo -e "${SEPARATOR}"
if [ ! -f ./${SERVER_CSR} ]; then
	echo "${LOG_TAG} FAIL to generate Server Certificate Sign Request (CSR)!"
	echo "${LOG_TAG} Check the script parameters and try again..."
	echo ""
	exit 1
fi
echo "${LOG_TAG} Server Certificate Sign Request (CSR) generated successfully!"

# Server V3 Extension File
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Generating V3 Extension File [v3.ext]"
echo -e ${V3_EXT} > v3.ext
echo ""
cat v3.ext

# Generating Server Certificate
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Generating Server Certificate Valid for ${SERVER_EXPIRE_DAYS} Days [${SERVER_CRT}]"
echo "${LOG_TAG} Signing Server Certificate with Root Certificate Authority"
echo ""
openssl x509 -req -in ${SERVER_CSR} -CA ${ROOT_CA_CRT} -CAkey ${ROOT_CA_KEY} -CAcreateserial -out ${SERVER_CRT} -days ${SERVER_EXPIRE_DAYS} -sha256 -extfile v3.ext

# Server Certificate Check
echo -e "${SEPARATOR}"
if [ ! -f ./${SERVER_CRT} ]; then
	echo "${LOG_TAG} FAIL to generate Server Certificate!"
	echo "${LOG_TAG} Check the script parameters and try again..."
	echo -e "${SEPARATOR}"
	exit 1
fi
echo "${LOG_TAG} Server Certificate generated successfully!"

# Finishing Certificate Chain Generation
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Certificate Chain Generation Finished Succesfully"
echo "${LOG_TAG} Certificate Authority................. ${ROOT_CA_CRT}"
echo "${LOG_TAG} Certificate Authority Key............. ${ROOT_CA_KEY}"
echo "${LOG_TAG} Server Certificate (Leaf)............. ${SERVER_CRT}"
echo "${LOG_TAG} Server Certificate (Leaf) Key......... ${SERVER_KEY}"

# Exporting Server Certificate to Keystore
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Exporting Server Certificate to PKCS12 Keystore [${SERVER_KEYSTORE}]"
echo ""
openssl pkcs12 -export -in ${SERVER_CRT} -inkey ${SERVER_KEY} -out ${SERVER_KEYSTORE} -certfile ${ROOT_CA_CRT} -name ${SERVER_CRT_ALIAS}

# Keystore Check
echo -e "${SEPARATOR}"
if [ ! -f ./${SERVER_KEYSTORE} ]; then
	echo "${LOG_TAG} FAIL to generate Keystore!"
	echo "${LOG_TAG} Check the script parameters and try again..."
	echo -e "${SEPARATOR}"
	exit 1
fi
echo "${LOG_TAG} Keystore generated successfully!"

# Print Server Certificate
echo -e "${SEPARATOR}"
openssl x509 -text -noout -in ${SERVER_CRT}

# Finishing Server Keystore Generation
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Server Keystore Generation Finished Succesfully"
echo "${LOG_TAG} Keystore............ ${SERVER_KEYSTORE}"
echo "${LOG_TAG} Certificate Alias... ${SERVER_CRT_ALIAS}"

# Removing Temporary Files
echo -e "${SEPARATOR}"
echo "${LOG_TAG} Removing Temporary Files"
rm -v server.csr.cnf v3.ext

# Root Certificate Authority Directory
echo -e "${SEPARATOR}"
if [ ! -d ${ROOT_CA_BASE_NAME} ]; then
	echo "${LOG_TAG} Creating Root Certificate Authority Directory [${ROOT_CA_BASE_NAME}]"
	mkdir -v ${ROOT_CA_BASE_NAME}

	echo ""
	echo "${LOG_TAG} Moving Root Certificate Authority Files to ./${ROOT_CA_BASE_NAME}/"
	mv -v ./${ROOT_CA_BASE_NAME}.* ./${ROOT_CA_BASE_NAME}/
	mv -v ./${ROOT_KEYSTORE} ./${ROOT_CA_BASE_NAME}/
	mv -v ./${ROOT_CA_TRUSTSTORE} ./${ROOT_CA_BASE_NAME}/
else
	echo "${LOG_TAG} Removing Root Certificate Authority Temp Files"
	rm -v ./${ROOT_CA_BASE_NAME}.*
	rm -v ./${ROOT_KEYSTORE}
	rm -v ./${ROOT_CA_TRUSTSTORE}
fi

# Server Certificate Directory
echo -e "${SEPARATOR}"
if [ ! -d ${SERVER_BASE_NAME} ]; then
	echo "${LOG_TAG} Creating Server Certificate Directory [${SERVER_BASE_NAME}]"
	mkdir -v ${SERVER_BASE_NAME}

	echo ""
	echo "${LOG_TAG} Moving Server Certificate Files to ./${SERVER_BASE_NAME}/"
	mv -v ./${SERVER_BASE_NAME}.* ./${SERVER_BASE_NAME}/
	mv -v ./${SERVER_KEYSTORE} ./${SERVER_BASE_NAME}/
fi

echo -e "${SEPARATOR}"
echo "${LOG_TAG} Script Finished!"
echo -e "${SEPARATOR}"

exit 0

