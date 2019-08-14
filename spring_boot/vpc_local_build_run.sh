#!/bin/bash

#########################################################################
######################    Virtual Private Cloud   #######################
#########################################################################
###################### Local Build and Run Script #######################
#########################################################################

# Local Run Absolute Path
LOCAL_RUN_BASE_PATH=$(pwd)

# Components Relative Base Path
SERVICE_1_BASE_PATH="../../service_1"
SERVICE_2_BASE_PATH="../../service_2"
SERVICE_3_BASE_PATH="../../service_3"
SERVICE_4_BASE_PATH="../../service_4"

# Components Relative Target Path
SERVICE_1_TARGET_PATH="${SERVICE_1_BASE_PATH}/target"
SERVICE_2_TARGET_PATH="${SERVICE_2_BASE_PATH}/target"
SERVICE_3_TARGET_PATH="${SERVICE_3_BASE_PATH}/target"
SERVICE_4_TARGET_PATH="${SERVICE_4_BASE_PATH}/target"

# Components Relative Jar Path
SERVICE_1_JAR_PATH="${SERVICE_1_TARGET_PATH}/service_1-0.0.1-SNAPSHOT.jar"
SERVICE_2_JAR_PATH="${SERVICE_2_TARGET_PATH}/service_2-0.0.1-SNAPSHOT.jar"
SERVICE_3_JAR_PATH="${SERVICE_3_TARGET_PATH}/service_3-0.0.1-SNAPSHOT.jar"
SERVICE_4_JAR_PATH="${SERVICE_4_TARGET_PATH}/service_4-0.0.1-SNAPSHOT.jar"

# Components Relative Application Properties Path
APPLICATION_PROPERTIES_REL_PATH="classes/application.properties"
SERVICE_1_PROP_PATH="${SERVICE_1_TARGET_PATH}/${APPLICATION_PROPERTIES_REL_PATH}"
SERVICE_2_PROP_PATH="${SERVICE_2_TARGET_PATH}/${APPLICATION_PROPERTIES_REL_PATH}"
SERVICE_3_PROP_PATH="${SERVICE_3_TARGET_PATH}/${APPLICATION_PROPERTIES_REL_PATH}"
SERVICE_4_PROP_PATH="${SERVICE_4_TARGET_PATH}/${APPLICATION_PROPERTIES_REL_PATH}"

# Dialog Settings
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_ESC=255}
DIALOG_HEIGHT=0
DIALOG_WIDTH=0
ACTIONS_DIALOG_ROWS=5
COMPONENTS_DIALOG_ROWS=8
DIALOG_DEFAULT_BACK_TITLE="Virtual Private Cloud"
DIALOG_DEFAULT_TITLE="Local Build and Run"
MONITOR_MESSAGE="Monitoring Processes?"
TERMINAL_GEOMETRY="100x35"

# Commands
RUN_COMMAND="java -jar"
BUILD_COMMAND="mvn clean install"
MONITORING_COMMAND="htop -d 1"

# Actions
BUILD_ACTION="Build"
RUN_ACTION="Run"
BUILD_AND_RUN_ACTION="Build and Run"

# Print logo
print_logo()
{
  echo ""
  echo "##### __     ______   ____  #####"
  echo "##### \\ \\   / /  _ \\ / ___| #####"
  echo "#####  \\ \\ / /| |_) | |     #####"
  echo "#####   \\ V / |  __/| |___  #####"
  echo "#####    \\_/  |_|    \\____| #####"
  echo ""
}


# Display Actions Menu
display_action_menu()
{
	# Duplicate file descriptor 1 on descreiptor 3
	exec 3>&1

	# Displaying Menu Dalog
	SELECTED_ACTION=$(dialog \
		--backtitle "${DIALOG_DEFAULT_BACK_TITLE}" \
		--title "${DIALOG_DEFAULT_TITLE}" \
		--clear \
		--ok-label "OK" \
		--cancel-label "EXIT" \
		--menu "Choose a action:" ${DIALOG_HEIGHT} ${DIALOG_WIDTH} ${ACTIONS_DIALOG_ROWS} \
			"1"  "Build Component(s)" \
			"2"  "Run   Component(s)" \
			""   "" \
			"9"  "Build and Run Component(s)" \
		2>&1 1>&3)

	# Getting exit status and closing file descriptor 3
	EXIT_STATUS=$?
	exec 3>&-
	clear

	# Check cancel actions
	case ${EXIT_STATUS} in
		${DIALOG_CANCEL})
			exit
			;;
		${DIALOG_ESC})
			exit
			;;
	esac
}


# Display Components Menu
display_components_menu()
{
	# Duplicate file descriptor 1 on descreiptor 3
	exec 3>&1

	# Displaying Menu Dalog
	SELECTED_COMPONENT=$(dialog \
		--backtitle "${DIALOG_DEFAULT_BACK_TITLE}" \
		--title "${DIALOG_DEFAULT_TITLE}" \
		--clear \
		--ok-label "OK" \
		--cancel-label "BACK" \
		--menu "Choose a component:" ${DIALOG_HEIGHT} ${DIALOG_WIDTH} ${COMPONENTS_DIALOG_ROWS} \
			"1"  "Service 1" \
			"2"  "Service 2" \
			"3"  "Service 3" \
			"4"  "Service 4" \
			"5"  "Databases" \
			""   "" \
			"9"  "All Components" \
		2>&1 1>&3)

	# Getting exit status and closing file descriptor 3
	EXIT_STATUS=$?
	exec 3>&-
	clear

	# Check components menu cancel actions
	case ${EXIT_STATUS} in
		${DIALOG_CANCEL})
			continue
			;;
		${DIALOG_ESC})
			continue
			;;
	esac
}


# Display result env vairable on dialog message box
display_result()
{
	MESSAGE="${ACTION} ${TITLE}\n\n${MONITOR_MESSAGE}"
	RESULT=$(print_logo; printf "${MESSAGE}")

	# Duplicate file descriptor 1 on descreiptor 3
	exec 3>&1

	dialog \
		--backtitle "${DIALOG_DEFAULT_BACK_TITLE}" \
		--title "${TITLE}" \
		--no-collapse \
		--yesno "${RESULT}" ${DIALOG_HEIGHT} ${DIALOG_WIDTH} \
		2>&1 1>&3

	# Getting exit status and closing file descriptor 3
	EXIT_STATUS=$?
	exec 3>&-
	clear

	# Check dialog exit status
	case ${EXIT_STATUS} in
		${DIALOG_OK}) # Monitoring Proccess
			${MONITORING_COMMAND}
			;;
	esac
}


# Build Command
# $1 -> Component Base Path
build()
{
	gnome-terminal --window --hide-menubar --geometry=${TERMINAL_GEOMETRY} -t ${TITLE} -- bash -c "cd $1 && ${BUILD_COMMAND} && cd ${LOCAL_RUN_BASE_PATH}; exec ${SHELL}"
}


# Run Command
# $1 -> Component Jar Path
run()
{
	gnome-terminal --window --hide-menubar --geometry=${TERMINAL_GEOMETRY} -t ${TITLE} -- bash -c "${RUN_COMMAND} $1; exec ${SHELL}"
}


# Build and Run Command
# $1 -> Component Base Path
# $2 -> Component Jar Path
build_run()
{
	gnome-terminal --window --hide-menubar --geometry=${TERMINAL_GEOMETRY} -t ${TITLE} -- bash -c "cd $1 && ${BUILD_COMMAND} && cd ${LOCAL_RUN_BASE_PATH} && ${RUN_COMMAND} $2; exec ${SHELL}"
}


# Execute Action
execute_action()
{
	case ${SELECTED_COMPONENT} in
		1) # Service 1
			TITLE="Service_1"
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					build ${SERVICE_1_BASE_PATH}
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					run ${SERVICE_1_JAR_PATH}
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					build_run ${SERVICE_1_BASE_PATH} ${SERVICE_1_JAR_PATH}
					display_result
					;;
			esac
			;;

		2) # Service 2
			TITLE="Service_2"
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					build ${SERVICE_2_BASE_PATH}
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					run ${SERVICE_2_JAR_PATH}
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					build_run ${SERVICE_2_BASE_PATH} ${SERVICE_2_JAR_PATH}
					display_result
					;;
			esac
			;;

		3) # Service 3
			TITLE="Service_3"
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					build ${SERVICE_3_BASE_PATH}
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					run ${SERVICE_3_JAR_PATH}
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					build_run ${SERVICE_3_BASE_PATH} ${SERVICE_3_JAR_PATH}
					display_result
					;;
			esac
			;;

		4) # Service 4
			TITLE="Service_4"
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					build ${SERVICE_4_BASE_PATH}
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					run ${SERVICE_4_JAR_PATH}
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					build_run ${SERVICE_4_BASE_PATH} ${SERVICE_4_JAR_PATH}
					display_result
					;;
			esac
			;;

		5) # Databases
			TITLE="Databases"
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					# TODO: Build Distributed Databases
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					# TODO: Run Distributed Databases
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					# TODO: Build and Run Distributed Databases
					display_result
					;;
			esac
			;;

		9) # All Components
			case ${SELECTED_ACTION} in
				1) # Build
					ACTION="${BUILD_ACTION}"
					TITLE="Service_1"
					build ${SERVICE_1_BASE_PATH}
					TITLE="Service_2"
					build ${SERVICE_2_BASE_PATH}
					TITLE="Service_3"
					build ${SERVICE_3_BASE_PATH}
					TITLE="Service_4"
					build ${SERVICE_4_BASE_PATH}
					TITLE="All_Components"
					display_result
					;;
				2) # Run
					ACTION="${RUN_ACTION}"
					TITLE="Service_1"
					run ${SERVICE_1_JAR_PATH}
					TITLE="Service_2"
					run ${SERVICE_2_JAR_PATH}
					TITLE="Service_3"
					run ${SERVICE_3_JAR_PATH}
					TITLE="Service_4"
					run ${SERVICE_4_JAR_PATH}
					TITLE="All_Components"
					display_result
					;;
				9) # Build and Run
					ACTION="${BUILD_AND_RUN_ACTION}"
					TITLE="Service_1"
					build_run ${SERVICE_1_BASE_PATH} ${SERVICE_1_JAR_PATH}
					TITLE="Service_2"
					build_run ${SERVICE_2_BASE_PATH} ${SERVICE_2_JAR_PATH}
					TITLE="Service_3"
					build_run ${SERVICE_3_BASE_PATH} ${SERVICE_3_JAR_PATH}
					TITLE="Service_4"
					build_run ${SERVICE_4_BASE_PATH} ${SERVICE_4_JAR_PATH}
					TITLE="All_Components"
					display_result
					;;
			esac
			;;
	esac
}


# Main Loop
while true;
do
	# Choose an action (Build / Run / Build and Run)
	display_action_menu

	# Check empty options
	if [ -z "${SELECTED_ACTION}" ]
	then
		continue
	fi

	# Choose an component
	display_components_menu

	# Check empty options
	if [ -z "${SELECTED_COMPONENT}" ]
	then
		continue
	fi

	# Execute Choosed Action
	execute_action

done

