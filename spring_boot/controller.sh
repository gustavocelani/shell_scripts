#!/bin/bash

#############################################################
#              JAR Server Controller Script                 #
#############################################################

# Workspace Absolute Path
WORKSPACE_PATH="/home/ubuntu/JAR_Server_Workspace"
# JAR Server PID File
PID_FILE="jar_server.pid"
# JAR Server Executable JAR File
JAR_FILE="jar-0.0.1-SNAPSHOT.jar"

# JAR Server Log File
LOG_FILE="jar-server.log"

# JAR Server PID Absolute Path
PID_PATH=${WORKSPACE_PATH}/${PID_FILE}
# JAR Server Executable JAR Absolute Path
JAR_PATH=${WORKSPACE_PATH}/${JAR_FILE}
# JAR Server Log Path
LOG_PATH=${WORKSPACE_PATH}/${LOG_FILE}
# JAR Server Access Log Path
ACCESS_LOG_PATH="/var/log/jar_server"

# REST APIs
declare -a REST_APIS=("rest_api_1" "rest_api_2" "rest_api_3" "rest_api_4")

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

#
# Start JAR Server with nohup and save system PID
#
start()
{
	if [ -e ${PID_PATH} ]; then
		echo "Is already Running..."
		echo "System PID: `cat ${PID_PATH}`"
		echo""
	else
		echo "Starting..."
		sudo nohup /usr/bin/java -jar ${JAR_PATH} > ${LOG_PATH} 2>&1 &
		sleep 1
		echo $!>${PID_PATH}
		echo ""
		echo "Log File:   ${LOG_PATH}"
		echo "System PID: `cat ${PID_PATH}`"
		echo ""
	fi
}

#
# Stop JAR Server killing the process by saved PID
#
stop()
{
	if [ -e ${PID_PATH} ]; then
		echo "Stopping..."
		echo "System PID: `cat ${PID_PATH}`"
		kill `cat ${PID_PATH}`
		rm ${PID_PATH}
		echo ""
	else
		echo "Is not Running..."
		echo""
	fi
}

#
# Check JAR Server Status
#
status()
{
	if [ -e ${PID_PATH} ]; then
		echo "Status: RUNNING"
		echo "PID:    `cat ${PID_PATH}`"
		echo ""
	else
		echo "Status: STOPPED"
		echo ""
	fi
}

#
# Log JAR Server
#
log()
{
	if [ -e ${LOG_PATH} ]; then
		echo "Showing logs..."
		cat ${LOG_PATH} | less
		echo ""
	else
		echo "No logs found..."
		echo ""
	fi
}

#
# Access Log
#
access_log()
{
	if [ -e ${ACCESS_LOG_PATH} ]; then
		echo "======================="
		echo "    All Access Log     "
		echo "-----------------------"
		echo " Count |    Source     "
		echo "-----------------------"
		sudo cat ${ACCESS_LOG_PATH}/* | awk -F ' ' '{ print $1}' | sort | uniq -c | sort -r
		echo "======================="
		echo ""

	else
		echo "No access logs found..."
		echo ""
	fi
}

#
# Print an API Log
#
print_api_log()
{
	echo "======================="
	echo " /${REST_API_NAME}"
	echo "-----------------------"
	echo " Count |    Source     "
	echo "-----------------------"
	sudo cat ${ACCESS_LOG_PATH}/* | grep "${RESP_API_NAME}" | awk -F ' ' '{ print $1}' | sort | uniq -c | sort -r
	echo "======================="
	echo ""
}

#
# REST APIs Log
#
api_log()
{
	if [ -e ${ACCESS_LOG_PATH} ];
	then
		for REST_API in "${REST_APIS[@]}";
		do
			REST_API_NAME = ${REST_API}
			print_api_log
		done
	else
		echo "No REST APIs logs found..."
		echo ""
	fi
}

# Print JAR Server Logo
print_logo

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	status)
		status
		;;
	log)
		log
		;;
	access-log)
		access_log
		;;
	api-log)
		api_log
		;;
	*)
		echo "Usage: jar-server {start|stop|restart|status|log|access-log|api-log}"
		echo ""
		echo "Start JAR Server........... jar-server start"
		echo "Stop JAR Server............ jar-server stop"
		echo "Restart JAR Server......... jar-server restart"
		echo "Status JAR Server.......... jar-server status"
		echo "Log JAR Server............. jar-server log"
		echo "Access Log JAR Server...... jar-server access-log"
		echo "REST APIs Log JAR Server... jar-server api-log"
		echo ""
		;;
esac

exit 0

